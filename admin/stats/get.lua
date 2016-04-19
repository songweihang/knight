local stats = require "apps.lib.stats"
local stats_center = stats:new()
local api = "api.model.getxxx"

local total,fail,success_time,fail_time,success_upstream_time,fail_upstream_time = stats_center:read_key_result(api,'match')

local strformat = string.format
-- 接口成功率
local success_ratio = strformat("%.3f",(total-fail)/total*100)
-- 成功接口请求平均时间
local success_avg_time_ratio = strformat("%.4f",success_time/(total-fail))
-- 成功接口上游请求时间
local success_avg_upstream_time_ratio = strformat("%.2f",success_upstream_time/(total-fail)*1000)

-- 失败接口请求平均时间
local fail_avg_time_ratio = strformat("%.2f",fail_time/fail*1000)
-- 失败接口上游请求时间
local fail_avg_upstream_time_ratio = strformat("%.4f",fail_upstream_time/fail)

--ngx.say(fail_avg_time_ratio..'ms')
ngx.say("成功接口(" .. api .. ")上游请求时间:" .. success_avg_upstream_time_ratio .. 'ms')
--[[


--ngx.shared.stats_match_total:delete(api)
local a = ngx.shared.stats_match_success_time:get(api)
ngx.say(a)
]]--

