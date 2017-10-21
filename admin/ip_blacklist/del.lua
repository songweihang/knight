local cjson           = require('cjson.safe')
local jencode         = cjson.encode
local cache           = require "apps.resty.cache"
local system_conf     = require "config.init"
local redis_conf      = system_conf.redisConf
local request         = require "apps.lib.request"

local args,method = request:get()

local ip = args['ip'] or nil
if not ip then
    ngx.print('IP is not empty')
    return
end

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return
end

local ip_blacklist, err = red.redis:srem('ip_blacklist',ip);
if err then
    ngx_log(ngx.ERR, "failed to query Redis:" .. err);
end
red:keepalivedb()

ngx.print('{"error":0,"message":"Success"}')