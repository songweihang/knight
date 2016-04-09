local modulename = "appsLibStats"

local _M = {}

_M._VERSION = '0.1'

local systemConf 				= require "config.init"
local statsConf 				= systemConf.statsConf

local statsCache       			= ngx.shared.stats
local statsAllCache       		= ngx.shared.statsAll
local ngxmatch         			= ngx.re.match
local match 		   			= string.match

_M.init = function ()
	--Initial stats
	statsCache:add(statsConf.http_total,0)
	statsCache:add(statsConf.http_fail,0)
	statsCache:add(statsConf.http_success_time,0)
	statsCache:add(statsConf.http_fail_time,0)
	statsCache:add(statsConf.http_success_upstream_time,0)
	statsCache:add(statsConf.http_fail_upstream_time,0)
end

_M.run = function()

	statsCache:incr(statsConf.http_total,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if tonumber(ngx.var.status) >= ngx.HTTP_BAD_REQUEST then
		-- HTTP FAIL 
		statsCache:incr(statsConf.http_fail,1)
		statsCache:incr(statsConf.http_fail_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			statsCache:incr(statsConf.http_fail_upstream_time,ngx.var.upstream_response_time)
		end
	else
		statsCache:incr(statsConf.http_success_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			statsCache:incr(statsConf.http_success_upstream_time,ngx.var.upstream_response_time)
		end
	end

	_M.statsAll()
end

local function statsMatch()
	
end

function _M.statsAll()

	local uri = ngx.var.uri
	if uri == nil then
		return
	end

	local statsAllConf = _M.initStatsAll(statsConf,uri)

	statsAllCache:incr(statsAllConf.http_total,1)
	if tonumber(ngx.var.status) >= ngx.HTTP_BAD_REQUEST then
		-- HTTP FAIL 
		statsAllCache:incr(statsAllConf.http_fail,1)
		statsAllCache:incr(statsAllConf.http_fail_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			statsAllCache:incr(statsAllConf.http_fail_upstream_time,ngx.var.upstream_response_time)
		end
	else
		statsAllCache:incr(statsAllConf.http_success_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			statsAllCache:incr(statsAllConf.http_success_upstream_time,ngx.var.upstream_response_time)
		end
	end

end

function _M.initStatsAll(statsConf,prefix)
	
	local prefix = '_'..prefix
	local StatsAllConf = {}
	--构建统计key
	StatsAllConf.http_total = statsConf.http_total..prefix
	StatsAllConf.http_fail = statsConf.http_fail..prefix
	StatsAllConf.http_success_time = statsConf.http_success_time..prefix
	StatsAllConf.http_fail_time = statsConf.http_fail_time..prefix
	StatsAllConf.http_success_upstream_time = statsConf.http_success_upstream_time..prefix
	StatsAllConf.http_fail_upstream_time = statsConf.http_fail_upstream_time..prefix

	-- 初始化统计值
	local ok, err = statsAllCache:add(StatsAllConf.http_total,0)
	if ok then
		statsAllCache:add(StatsAllConf.http_fail,0)
		statsAllCache:add(StatsAllConf.http_success_time,0)
		statsAllCache:add(StatsAllConf.http_fail_time,0)
		statsAllCache:add(StatsAllConf.http_success_upstream_time,0)
		statsAllCache:add(StatsAllConf.http_fail_upstream_time,0)
	end

	return StatsAllConf	
end

return _M