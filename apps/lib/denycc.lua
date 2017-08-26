-- Copyright (C) 2016-2017 WeiHang Song (Jakin)
-- 基于Redis实现ip频率限制的集群cc防御


local _M = {
    _VERSION = '0.01'
}

local system_conf            = require "config.init"
local redis_conf             = system_conf.redisConf
local denycc_rate_conf       = system_conf.denycc_rate_conf
local ngxshared              = ngx.shared
local denycc_conf            = ngxshared.denycc_conf

_M.denycc_run = function()
    local denycc_rate_ts         = denycc_conf:get('denycc_rate_ts') or denycc_rate_conf.ts
    local denycc_rate_request    = denycc_conf:get('denycc_rate_request') or denycc_rate_conf.request
    local ip_parser              = require "apps.lib.ip_parser"
    local ip                     = ip_parser:get()
    local ts                     = math.ceil(ngx.time()/denycc_rate_ts)
    local limit                  = 'LIMIT:' .. ip .. ':' .. ts

    local redis = require "apps.resty.redis"
    local red = redis:new()

    red:set_timeout(redis_conf['timeout']) -- 1 sec

    local ok, err = red:connect(redis_conf['host'], redis_conf['port'])
    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err)
        return
    else
        if redis_conf['auth'] ~= nil then
            red:auth(redis_conf['auth'])
        end
        red:select(redis_conf['dbid'])    
    end

    local hit, err = red:incr(limit)

    if hit == 1 then
        red:expire(limit,denycc_rate_ts)
    end

    local ok, err = red:set_keepalive(redis_conf['idletime'], redis_conf['poolsize'])
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        return
    end

    if hit >= denycc_rate_request then
        ngx.header["Content-Type"] = "text/html; charset=UTF-8"
        ngx.header["NGX-DENYCC-HIT"] = hit
        ngx.exit(429)
        ngx.log(ngx.ERR, "denycc ip: ", ip)
        return
    else
        ngx.header["NGX-DENYCC-HIT"] = hit
        --ngx.say(limit .. ":" .. hit)    
    end
end


return _M