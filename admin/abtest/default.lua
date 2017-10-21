local cjson             = require('cjson.safe')
local system_conf       = require "config.init"
local redis_conf        = system_conf.redisConf
local cache             = require "apps.resty.cache"
local request           = require "apps.lib.request"

local is_null = function(v)
    return v and v ~= ngx.null
end

local AB_DEF_UPS        = "abtest:default:upstream:"
local AB_UPS            = "abtest:upstream:"
local AB_UPS_APPOINT    = "abtest:upstream:appoint:"
local args,method       = request:get()
local host              = args['host'] or nil
local appoint           = args['appoint'] or nil

if not host then
    ngx.print('{"code":50001,"message":"ERROR: expected parameter for" }')
    return
end

-- [{"ip": "127.0.0.1","port": 8080,"weight":10},{"ip": "127.0.0.1","port": 8080,"weight":5}]
if appoint then
    local appoint_table = cjson.decode(appoint)
    if type(appoint_table) ~= 'table' then
        ngx.print('{"code":40003,"message":"ERROR: appoint is not a table"}')
        return
    else
        for _, v in pairs(appoint_table) do
            if not v['ip'] or not tonumber(v['port']) or not tonumber(v['weight']) then
                ngx.print('{"code":40003,"message":"ERROR: expected parameter for" }')
                return
            end
        end
    end
end

local red = cache:new(redis_conf)
local ok, err = red:connectdb()
if not ok then
    return 
end

if method == 'GET' then
    local def_ups_cache ,_ = red.redis:get(AB_DEF_UPS .. host)
    ngx.print(def_ups_cache) 
end

if method == 'POST' then
    if not appoint then
        ngx.print('{"code":40004,"message":"expected parameter for" }')
        red:keepalivedb()
        return
    else
        red.redis:set(AB_DEF_UPS .. host,appoint)
    end 
    ngx.print('{"code":0,"message":"success"}') 
end

if method == 'DELETE' then
    red.redis:del(AB_DEF_UPS .. host)
    ngx.print('{"code":0,"message":"success"}') 
end

red:keepalivedb()