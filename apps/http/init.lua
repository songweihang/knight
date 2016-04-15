local statsCache 				= ngx.shared.stats
local systemConf 				= require "config.init"
local statsMainConf 			= systemConf.statsMainConf

--local stats = require "apps.lib.stats"
--local statsRun = stats:new()
--statsRun:add_stats_num_cache('stats',statsMainConf)
--[[
local function add_stats_num_cache(cache,conf)

	if ok then
		cache:add(conf.http_fail,0)
		cache:add(conf.http_success_time,0)
		cache:add(conf.http_fail_time,0)
		cache:add(conf.http_success_upstream_time,0)
		cache:add(conf.http_fail_upstream_time,0)
	end
end

add_stats_num_cache(statsCache,statsMainConf)
]]--