local require						= require
local tonumber 						= tonumber
local pairs							= pairs
local ipairs						= ipairs
local ngxmatch         				= ngx.re.match
local ngx_shared 					= ngx.shared


local systemConf 					= require "config.init"
local statsPrefixConf 				= systemConf.statsPrefixConf
local statsMatchConf				= systemConf.statsMatchConf
local statsAllSwitchConf			= systemConf.statsAllSwitchConf
local statsMatchSwitchConf			= systemConf.statsMatchSwitchConf

local ngx_var 						= ngx.var
local status 						= tonumber(ngx_var.status)
local uri               			= ngx_var.uri or ''
local host 							= ngx_var.host
local request_time      			= ngx_var.request_time or 0
local upstream_response_time      	= ngx_var.upstream_response_time or 0


local stats = require "apps.lib.stats"

-- 全局统计
local statsRun = stats:new(status,uri,host,request_time,upstream_response_time)
statsRun:incrStatsNumCache(ngx_shared['stats'],statsPrefixConf)

-- 全局urL统计
if statsAllSwitchConf then

	--[[ 
		较大cpu占用时间 待优化
	]]--
	local StatsAllConf = {}
	local prefix = host..uri
	for k, v in pairs(statsPrefixConf) do
		StatsAllConf[k] = v..prefix
	end
	statsRun:incrStatsNumCache(ngx_shared['statsAll'],StatsAllConf)
end

-- 正则匹配统计
if statsMatchSwitchConf == false then
	return
end

local request_method,body = ngx_var.request_method

if request_method == 'GET' and request_method == 'DELETE'  
	and request_method == 'HEAD' and request_method == 'OPTIONS' then

	body = uri
else
	body = ngx_var.request_body
	if body ~= nil then
		body = body..uri
	else
		body = uri	
	end
end

-- 获取正则特殊定制统计
for i, v in ipairs(statsMatchConf) do
	if v['switch'] then
		local m = ngxmatch(body, v['match'],"o")
	    if m then 
	        --ngx.say(m[0])
	        --statsRun:incrStatsNumCache(ngx_shared['statsMatch'],m[0])
	    end
	end
end
