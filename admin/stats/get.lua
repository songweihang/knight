ngx.header["Content-Type"] = "application/json;charset=UTF-8"

local strformat = string.format
local tonumber  = tonumber
local tableinsert = table.insert

local function api_count(key,total,fail,success_time,fail_time,success_upstream_time,fail_upstream_time,bytes_sent)
    local success_total = total-fail
    -- 接口成功率
    local success_ratio = strformat("%.3f",success_total/total*100)
    local success_time_avg,success_upstream_time_avg,fail_time_avg,fail_upstream_time_avg = '0.00','0.00','0.00','0.00'
    if success_total > 0 then
        -- 成功接口请求平均时间
        success_time_avg = strformat("%.2f",success_time/success_total*1000)
        -- 成功接口上游请求时间
        success_upstream_time_avg = strformat("%.2f",success_upstream_time/success_total*1000)
    end

    if fail > 0 then
        -- 失败接口请求平均时间
        fail_time_avg = strformat("%.2f",fail_time/fail*1000)
        -- 失败接口上游请求时间
        fail_upstream_time_avg = strformat("%.2f",fail_upstream_time/fail*1000)
    end

    local flow_all = strformat("%.2f",bytes_sent/1024/1024)
    local flow_avg = strformat("%.2f",bytes_sent/1024/total)

    return {
        ["api"] = key,
        ["total"] = total,
        ["fail"] = fail,
        ["success_ratio"] = success_ratio,
        ["success_time"] = success_time*1000,
        ["fail_time"] = fail_time*1000,
        ["success_upstream_time"] = success_upstream_time,
        ["success_time_avg"] = success_time_avg,
        ["success_upstream_time_avg"] = success_upstream_time_avg,
        ["fail_time_avg"] = fail_time_avg,
        ["fail_upstream_time_avg"] = fail_upstream_time_avg,
        ["flow_all"] = flow_all,
        ["flow_avg"] = flow_avg
    }
end

local cjson = require('cjson.safe')
-- 编码
local jencode = cjson.encode

local system_conf = require "config.init"
local redis_conf  = system_conf.redisConf
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

local lists = {}
local results, err = red:keys('knightapi-*')

for i, key in ipairs(results) do
    local total = red:hget(key,'total')
    local fail = red:hget(key,'fail')
    local success_time = red:hget(key,'success_time')
    local fail_time = red:hget(key,'fail_time')
    local success_upstream_time = red:hget(key,'success_upstream_time')
    local fail_upstream_time = red:hget(key,'fail_upstream_time')
    local bytes_sent = red:hget(key,'bytes_sent')
    local ratio = api_count(key,tonumber(total),tonumber(fail),success_time,fail_time,success_upstream_time,fail_upstream_time,bytes_sent)
    if ratio ~= nil then
        tableinsert(lists,ratio)
    end
end

local ok, err = red:set_keepalive(redis_conf['idletime'], redis_conf['poolsize'])
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    return
end

ngx.print(jencode(lists))