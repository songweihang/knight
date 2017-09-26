ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local cjson           = require('cjson.safe')
local jencode         = cjson.encode
local cache           = require "apps.resty.cache"
local system_conf     = require "config.init"
local redis_conf      = system_conf.redisConf

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return
end

local ip_blacklist, err = red.redis:smembers('ip_blacklist');
if err then
    ngx_log(ngx.ERR, "failed to query Redis:" .. err);
end
red:keepalivedb()

ngx.print(jencode(ip_blacklist))