--[[

]]--
local statsCache       						= ngx.shared.stats
local statsAllCache       					= ngx.shared.statsAll
local statsMatchCache        				= ngx.shared.statsMatch

local systemConf 							= require "config.init"
local statsPrefixConf 						= systemConf.statsPrefixConf
local statsMatchConf						= systemConf.statsMatchConf
local statsAllSwitchConf					= systemConf.statsAllSwitchConf

local ngx_var_status 						= ngx.var.status
local ngx_var_uri               			= ngx.var.uri or ''
local ngx_var_host 							= ngx.var.host
local ngx_var_request_time      			= ngx.var.request_time or 0
local ngx_var_upstream_response_time      	= ngx.var.upstream_response_time or 0

local stats = require "apps.lib.stats"

local statsRun = stats:new(
	ngx_var_status,
	ngx_var_uri,
	ngx_var_host,
	ngx_var_request_time,
	ngx_var_upstream_response_time
)

statsRun:incrStatsNumCache(statsCache,statsPrefixConf)
--stats.statsAll()
--stats.statsMatch()