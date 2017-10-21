local cjson             = require('cjson.safe')
local system_conf       = require "config.init"
local redis_conf        = system_conf.redisConf
local cache             = require "apps.resty.cache"
local request           = require "apps.lib.request"

local is_null = function(v)
    return v and v ~= ngx.null
end

local AB_UPS         = "abtest:upstream:"
local AB_UPS_APPOINT = "abtest:upstream:appoint:"
local args,method    = request:get()
local host           = args['host'] or nil
local appoint_id     = tonumber(args['appoint_id']) or 0

if not host then
    ngx.print('{"code":50001,"message":"ERROR: expected parameter for" }')
    return
end

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return 
end

if method == 'GET' then
    local appoint_id,err = red.redis:get(AB_UPS .. host)
    if is_null(appoint_id) then
        appoint ,_ = red.redis:get(AB_UPS_APPOINT .. appoint_id)
        ngx.print(appoint)
        red:keepalivedb()
        return     
    end
end

if method == 'POST' then
    red.redis:set(AB_UPS .. host,appoint_id)
    ngx.print('{"code":0,"message":"success"}') 
end

if method == 'DELETE' then
    red.redis:del(AB_UPS .. host)
    ngx.print('{"code":0,"message":"success"}') 
end

red:keepalivedb()