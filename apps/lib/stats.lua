local modulename = "appsLibStats"

local _M = {}

_M._VERSION = '0.1'

local systemConf 				= require "config.init"
local statsConf 				= systemConf.statsConf

local statsCache       			= ngx.shared.stats
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
		statsCache:incr(statsConf.http_fail_upstream_time,ngx.var.upstream_response_time)
	else
		statsCache:incr(statsConf.http_success_time,ngx.var.request_time)
		statsCache:incr(statsConf.http_success_upstream_time,ngx.var.upstream_response_time)
	end
end



return _M