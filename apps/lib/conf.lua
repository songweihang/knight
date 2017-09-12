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
local delay                  = 5

local set_conf_value = function(key,value)
    local value = tonumber(value)
    if value then
        denycc_conf:set(key,value)
    end
end


local function set_conf(premature,redis_conf)
    local red = cache:new(redis_conf)
    local ok, err = red:connectdb()
    if not ok then
        return 
    end

    local conf_key = {"denycc_switch","denycc_rate_request","denycc_rate_ts"}
    for i,v in ipairs(conf_key) do  
        local res, err = red.redis:get(v)
        set_conf_value(v,res)
    end

    red:keepalivedb()

    timer_at(delay,set_conf,redis_conf)

    ngx.log(ngx.ERR, "set_conf timer_at ing...",delay)
end


function _M.timer_at_redis()
    local ok, err = timer_at(delay,set_conf,redis_conf)

    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

return _M