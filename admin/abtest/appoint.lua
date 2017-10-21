local cjson             = require('cjson.safe')
local system_conf       = require "config.init"
local redis_conf        = system_conf.redisConf
local cache             = require "apps.resty.cache"
local ipappoint         = require "apps.lib.abtest.upstream.ipappoint"
local uidappoint        = require "apps.lib.abtest.upstream.uidappoint"
local request           = require "apps.lib.request"

local AB_UPS_APPOINT = "abtest:upstream:appoint:"
local args,method    = request:get()
local appoint        = args['appoint'] or nil
local appoint_id     = tonumber(args['appoint_id']) or nil

-- 检查appoint是否符合规则
if appoint then
    local appoint_table = cjson.decode(appoint)
    if type(appoint_table) ~= 'table' then
        ngx.print('{"code":40003,"message":"ERROR: appoint is not a table"}')
        return
    else
        if appoint_table.divtype ~= 'uidrange' and appoint_table.divtype ~= 'iprange' then
            ngx.print('{"code":40003,"message":"ERROR: divtype in uidrange or iprange"}')
            return
        else
            if appoint_table.divtype == 'uidrange' then
                local uua = uidappoint:new(appoint_table['divdata'])
                local check = uua:check()
                if not check then
                    ngx.print('{"code":40003,"message":"ERROR: appoint expected parameter for" }')
                    return
                end
            end

            if appoint_table.divtype == 'iprange' then
                local uua = ipappoint:new(appoint_table['divdata'])
                local check = uua:check()
                if not check then
                    ngx.print('{"code":40003,"message":"ERROR: appoint expected parameter for" }')
                    return
                end
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
    if appoint_id then
        appoint ,_ = red.redis:get(AB_UPS_APPOINT .. appoint_id)
    end

    ngx.print(appoint)
end

if method == 'DELETE' then
    if appoint_id then
        appoint ,_ = red.redis:del(AB_UPS_APPOINT .. appoint_id)
    end

    ngx.print('{"code":0,"message":"success"}') 
end

if method == 'POST' then
    if not appoint then
        ngx.print('{"code":40004,"message":"ERROR: appoint expected parameter for" }')
        red:keepalivedb()
        return
    else
        if not appoint_id then
            appoint_id = red.redis:incr(AB_UPS_APPOINT .. 'incr')
        end

        red.redis:set(AB_UPS_APPOINT .. appoint_id,appoint)
    end

    ngx.print('{"appoint_id":' .. appoint_id .. '}')    
end

red:keepalivedb()
