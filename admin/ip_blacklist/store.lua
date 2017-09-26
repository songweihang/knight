ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local cjson           = require('cjson.safe')
local jencode         = cjson.encode
local cache           = require "apps.resty.cache"
local system_conf     = require "config.init"
local redis_conf      = system_conf.redisConf

local GET,method = nil,ngx.var.request_method
ngx.req.read_body()
if method == 'GET' then
    GET = ngx.req.get_uri_args()
end

local ip = GET['ip'] or nil
if not ip then
    ngx.print('IP is not empty')
    return
end

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return
end

local ip_blacklist, err = red.redis:sadd('ip_blacklist',ip);
if err then
    ngx_log(ngx.ERR, "failed to query Redis:" .. err);
end
red:keepalivedb()

ngx.print('{"error":0,"message":"Success"}')