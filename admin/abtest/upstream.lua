local cjson             = require('cjson.safe')
local system_conf       = require "config.init"
local redis_conf        = system_conf.redisConf
local cache             = require "apps.resty.cache"
local request           = require "apps.lib.request"

local AB_UPS      = "abtest:upstream:"
local args,method = request:get()
local host        = args['host'] or nil
local appoint_id  = tonumber(args['appoint_id']) or nil

if not host or not appoint_id then
    ngx.print('{"code":50001,"message":"ERROR: expected parameter for" }')
    return
end

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return 
end

red.redis:set(AB_UPS .. host,appoint_id)

ngx.print('{"code":0,"message":"Save upstream appoint_id"}') 
red:keepalivedb()