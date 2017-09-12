ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local cjson             = require('cjson.safe')
local jencode           = cjson.encode
local system_conf       = require "config.init"
local denycc_rate_conf  = system_conf.denycc_rate_conf
local ngxshared         = ngx.shared
local denycc_conf       = ngxshared.denycc_conf
local redis_conf        = system_conf.redisConf
local cache             = require "apps.resty.cache"

local GET,method = nil,ngx.var.request_method
ngx.req.read_body()
if method == 'GET' then
    GET = ngx.req.get_uri_args()
end

local denycc_switch = tonumber(GET['denycc_switch']) or 0
if denycc_switch == 0 then
    denycc_switch = 0
else
    denycc_switch = 1
end
local denycc_rate_request = tonumber(GET['denycc_rate_request']) or denycc_rate_conf.request
local denycc_rate_ts = tonumber(GET['denycc_rate_ts']) or denycc_rate_conf.ts

denycc_conf:set('denycc_switch',denycc_switch)
denycc_conf:set('denycc_rate_request',denycc_rate_request)
denycc_conf:set('denycc_rate_ts',denycc_rate_ts)

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return 
end

red.redis:set('denycc_switch',denycc_switch)
red.redis:set('denycc_rate_request',denycc_rate_request)
red.redis:set('denycc_rate_ts',denycc_rate_ts)

red:keepalivedb()

local config = {
    ["denycc_switch"] = denycc_switch,
    ["denycc_rate_request"] = denycc_rate_request,
    ["denycc_rate_ts"] = denycc_rate_ts
}

ngx.print(jencode(config))