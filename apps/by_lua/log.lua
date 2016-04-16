local ngx_find                      = ngx.re.find
local string_sub                    = string.sub
local system_conf                   = require "config.init"
local stats_main_conf               = system_conf.stats_main_conf
local stats_match_conf              = system_conf.stats_match_conf
local stats_all_switch              = system_conf.stats_all_switch
local stats_match_switch            = system_conf.stats_match_switch

local status                        = tonumber(ngx.var.status) or 499
local uri                           = ngx.var.uri or ''
local host                          = ngx.var.host or 'host'
local request_time                  = ngx.var.request_time or 0
local upstream_response_time        = ngx.var.upstream_response_time or 0

local stats = require "apps.lib.stats"
local statsRun = stats:new(status,request_time,upstream_response_time)


-- 全局urL统计
if stats_all_switch then
	local hostUri = host .. uri
	statsRun:incr_stats_num_cache(hostUri,"all")
end


-- 正则匹配统计
if stats_match_switch then

	local request_data = statsRun:request_data(uri)

	-- 获取正则特殊定制统计
	for i, v in ipairs(stats_match_conf) do
		if v['switch'] and host == v['host'] then
			local from,to,err = ngx_find(request_data, v['match'],"jo")
		    if from then 
		        local matched = string_sub(request_data,from,to)
		        statsRun:incr_stats_num_cache(matched,"match")
		    end
		end
	end
end


