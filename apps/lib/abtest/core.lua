-- Copyright (C) 2016-2017 WeiHang Song (Jakin)

local ipappoint         = require "apps.lib.abtest.upstream.ipappoint"
local uidappoint        = require "apps.lib.abtest.upstream.uidappoint"
local uidparser         = require "apps.lib.abtest.userinfo.uidparser"
local ipparser          = require "apps.lib.abtest.userinfo.ipparser"
local system_conf       = require "config.init"
local cache             = require "apps.resty.cache"
local lrucache          = require "resty.lrucache"
local cjson             = require('cjson.safe')
local semaphore         = require "ngx.semaphore"
local redis_conf        = system_conf.redisConf
local ngx_log           = ngx.log
local tonumber          = tonumber
local type              = type
local timer_at          = ngx.timer.at
local ngxshared         = ngx.shared
local math_random       = math.random


local _M    = {}
local mt    = { __index = _M }
_M._VERSION = "0.1"

local DEFAULT_UPSTREAM_LOCK_WAIT = math_random(50,60)
local UPSTREAM_LOCK_WAIT         = math_random(50,60)
local UPSTREAM_APPOINT_LOCK_WAIT = math_random(50,60)
local SEMA_WAIT                  = 0.01


local get_host = function ()
    return ngx.var.host
end


local is_null = function(v)
    return v and v ~= ngx.null
end

local upstream_weight_shunt = function (upstream)
    local weight = 0
    local tempdata = {}
    for _, v in pairs(upstream) do
        weight = v['weight'] + weight;
        for i = 1,v['weight'],1 do
            table.insert(tempdata,v)
        end
    end
    local index = math_random(1, weight);
    return tempdata[index];
end

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c, err = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end


local function generate_abtest_upstream_id(premature,host)
    local red = cache:new(redis_conf)
    local ok, err = red:connectdb()
    if not ok then
        return 
    end

    local abtest_upstream_id, err  = red.redis:get('abtest:upstream:' .. host)
    if not abtest_upstream_id then
      ngx_log(ngx.ERR, "failed to query Redis: ", err)
      return 
    end
    red:keepalivedb()
    -- 获取redis数据写入 ngx.shared.abtest
    if is_null(abtest_upstream_id) then
        ngxshared.abtest:set('abtest:upstream:' .. host,abtest_upstream_id)
    else
        ngxshared.abtest:delete('abtest:upstream:' .. host)
    end
    ngx_log(ngx.ERR, "generate_abtest_upstream_id:",host)
end


local function generate_abtest_default_upstream(premature,host,default_upstream_conf)
    local red = cache:new(redis_conf)
    local ok, err = red:connectdb()
    if not ok then
        -- 无法连接redis 写入默认upstream
        c:set('abtest:default:upstream:' .. host,default_upstream_conf)
        return 
    end

    local default_upstream, err  = red.redis:get('abtest:default:upstream:' .. host)
    if not default_upstream then
      ngx_log(ngx.ERR, "failed to query Redis: ", err)
      return 
    end

    red:keepalivedb()
    -- 获取redis数据写入 ngx.shared.abtest
    if is_null(default_upstream) then
        c:set('abtest:default:upstream:' .. host,cjson.decode(default_upstream))
    else
        c:set('abtest:default:upstream:' .. host,default_upstream_conf)
    end
    ngx_log(ngx.ERR, "generate_abtest_default_upstream:",host) 
end


local function generate_abtest_appoint(premature,upstream_id)
    local red = cache:new(redis_conf)
    local ok, err = red:connectdb()
    if not ok then
        return 
    end

    local upstream_appoint, err  = red.redis:get('abtest:upstream:appoint:' .. upstream_id)
    if not upstream_appoint then
      ngx_log(ngx.ERR, "failed to query Redis: ", err)
      return 
    end

    red:keepalivedb()
    -- 获取redis数据写入 ngx.shared.abtest
    if is_null(upstream_appoint) then
        c:set('abtest:upstream:appoint:' .. upstream_id, cjson.decode(upstream_appoint))
    else
        c:delete('abtest:upstream:appoint:' .. upstream_id)
    end
    ngx_log(ngx.ERR, "generate_abtest_appoint:",upstream_id)
end


local get_upstream_id = function (host)
    -- step 1 read frome cache, but error
    local upstream_lock = ngxshared.abtest:get("abtest:upstream:lock:" .. host)

    if not upstream_lock then
        local sema = semaphore.new()
        -- abtest upstream 读取规则失败 尝试在redis中获取
        -- step 2 semaphore lock
        local sem, err = sema:wait(SEMA_WAIT)
        if not sem then
            -- lock failed acquired
            -- but go on. This action just sets a fence 
        end

        -- step 3 再次读区是否存在该缓存
        local upstream_lock = ngxshared.abtest:get("abtest:upstream:lock:" .. host)
        if not upstream_lock then
            -- step 4 读取redis获取数据
            timer_at(0, generate_abtest_upstream_id,host)
            ngxshared.abtest:set('abtest:upstream:lock:' .. host,1,UPSTREAM_LOCK_WAIT)
        end

        if sem then sema:post(1) end
    end
    local upstream_id = ngxshared.abtest:get("abtest:upstream:" .. host)
    return upstream_id
end


local get_upstream_appoint = function (upstream_id)
    local upstream_appoint_lock = c:get("abtest:upstream:appoint:lock:" .. upstream_id)
    if not upstream_appoint_lock then
        local sema = semaphore.new()
        -- abtest upstream 读取规则失败 尝试在redis中获取
        -- step 2 semaphore lock
        local sem, err = sema:wait(SEMA_WAIT)
        if not sem then
            -- lock failed acquired
            -- but go on. This action just sets a fence 
        end

        -- step 3 再次读区是否存在该缓存
        local upstream_appoint_lock = c:get("abtest:upstream:appoint:lock:" .. upstream_id)
        if not upstream_appoint_lock then
            -- step 4 读取redis获取数据
            timer_at(0, generate_abtest_appoint,upstream_id)
            c:set('abtest:upstream:appoint:lock:' .. upstream_id, 1,UPSTREAM_APPOINT_LOCK_WAIT)
        end

        if sem then sema:post(1) end
    end

    return c:get("abtest:upstream:appoint:" .. upstream_id)
end


function _M.get_upstream()
    local upstream          = nil
    local host              = get_host()
    local upstream_id       = get_upstream_id(host)
    if not upstream_id then
        return upstream
    end
    
    local upstream_appoint  = get_upstream_appoint(upstream_id)
    if type(upstream_appoint) == 'table' and type(upstream_appoint['divdata']) == 'table' then
        -- ngx_log(ngx.ERR, "upstream_appoint: ", cjson.encode(upstream_appoint))
        if upstream_appoint.divtype == 'uidrange' then
            local uua = uidappoint:new(upstream_appoint['divdata'])
            local upstream = uua:get_upstream(uidparser:get())
            return upstream
        end

        if upstream_appoint.divtype == 'iprange' then
            local uua = ipappoint:new(upstream_appoint['divdata'])
            local upstream = uua:get_upstream(ipparser:get())
            return upstream
        end
    end

    return upstream
end  


function _M.get_default_upstream()
    local host,default_upstream = get_host(),ngx.var.default_upstream or nil
    local default_upstream_lock = c:get("abtest:default:upstream:lock:" .. host)    
    if not default_upstream_lock then
        default_upstream  = cjson.decode(default_upstream)
        local sema = semaphore.new()
        -- abtest upstream 读取规则失败 尝试在redis中获取
        -- step 2 semaphore lock
        local sem, err = sema:wait(SEMA_WAIT)
        if not sem then
            -- lock failed acquired
            -- but go on. This action just sets a fence 
        end

        -- step 3 再次读区是否存在该缓存
        local default_upstream_lock = c:get("abtest:default:upstream:lock:" .. host)
        if not default_upstream_lock then
            -- step 4 读取redis获取数据
            if type(default_upstream) == 'table' then
                timer_at(0, generate_abtest_default_upstream,host,default_upstream)
                c:set('abtest:default:upstream:lock:' .. host,1,DEFAULT_UPSTREAM_LOCK_WAIT)
            end
        end
        if sem then sema:post(1) end
    end

    local default_upstream_cache = c:get("abtest:default:upstream:" .. host)
    -- default_upstream = default_upstream_cache or default_upstream
    if default_upstream_cache then
        default_upstream = default_upstream_cache            
    end
    if type(default_upstream) ~= 'table' then
        default_upstream  = cjson.decode(default_upstream)
    end
    if default_upstream then
        local upstream = upstream_weight_shunt(default_upstream)
        return upstream
    end

    return nil
end


return _M