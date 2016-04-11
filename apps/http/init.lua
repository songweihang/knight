--local stats = require "apps.lib.stats".init()

local statsCache 				= ngx.shared.stats
local systemConf 				= require "config.init"
local statsPrefixConf 			= systemConf.statsPrefixConf

--[[
	初始化统计缓存
	@param cache ngx_shared 
    @param table conf
    @return 
]]--
local function intStatsNumCache(cache,conf)

	local ok, err = cache:add(conf.http_total,0)
	if ok then
		cache:add(conf.http_fail,0)
		cache:add(conf.http_success_time,0)
		cache:add(conf.http_fail_time,0)
		cache:add(conf.http_success_upstream_time,0)
		cache:add(conf.http_fail_upstream_time,0)
	end
end


intStatsNumCache(statsCache,statsPrefixConf)