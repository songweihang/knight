-- Copyright (C) 2016-2017 WeiHang Song (Jakin)
-- 基于Redis实现集群服务配置


local _M = {
    _VERSION = '0.01'
}

local system_conf            = require "config.init"
local redis_conf             = system_conf.redisConf
local denycc_rate_conf       = system_conf.denycc_rate_conf
local ngxshared              = ngx.shared
local denycc_conf            = ngxshared.denycc_conf
local cache                  = require "apps.resty.cache"
local timer_at               = ngx.timer.at
local ngx_log                = ngx.log
local delay                  = 5

local set_shared_value = function(shared,key,value)
    local value = tonumber(value)
    if value then
        ngxshared[shared]:set(key,value)
    end
end


local function set_conf(premature,redis_conf)
    local red = cache:new(redis_conf)
    local ok, err = red:connectdb()
    if not ok then
        ngx_log(ngx.ERR, "set_conf timer_at ERROR ",err)
        timer_at(delay,set_conf,redis_conf)
        return 
    end

    local conf_key = {"denycc_switch","denycc_rate_request","denycc_rate_ts"}
    for i,v in ipairs(conf_key) do  
        local res, err = red.redis:get(v)
        set_shared_value('denycc_conf',v,res)
    end

    local ip_blacklist, err = red.redis:smembers('ip_blacklist');
    if err then
        ngx_log(ngx.ERR, "failed to query Redis:" .. err);
    else
        ngxshared['ip_blacklist_conf']:flush_all();
        for index, banned_ip in ipairs(ip_blacklist) do
            local cache_banned_ip = 'banned_ip:' .. banned_ip
            ngx_log(ngx.ERR, "failed to query cache_banned_ip:" .. cache_banned_ip);
            set_shared_value('ip_blacklist_conf',cache_banned_ip,1)
        end
    end

    red:keepalivedb()
    ngx_log(ngx.ERR, "set_conf timer_at ing...",delay)
    timer_at(delay,set_conf,redis_conf)
end


function _M.timer_at_redis()
    local ok, err = timer_at(delay,set_conf,redis_conf)

    if not ok then
        ngx_log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

return _M