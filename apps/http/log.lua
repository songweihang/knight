local tonumber 						= tonumber
local ngxmatch         				= ngx.re.match
--local match 		   				= string.match
local ngx_shared 					= ngx.shared
--local statsCache       			= ngx.shared.stats
--local statsAllCache       		= ngx.shared.statsAll
--local statsMatchCache        		= ngx.shared.statsMatch

local systemConf 					= require "config.init"
local statsPrefixConf 				= systemConf.statsPrefixConf
local statsMatchConf				= systemConf.statsMatchConf
local statsAllSwitchConf			= systemConf.statsAllSwitchConf

local status 						= tonumber(ngx.var.status)
local uri               			= ngx.var.uri or ''
local host 							= ngx.var.host
local request_time      			= ngx.var.request_time or 0
local upstream_response_time      	= ngx.var.upstream_response_time or 0


local stats = require "apps.lib.stats"

-- 全局统计
local statsRun = stats:new(status,uri,host,request_time,upstream_response_time)
statsRun:incrStatsNumCache(ngx_shared['stats'],statsPrefixConf)

-- 全局urL统计
if statsAllSwitchConf then

	local StatsAllConf = {}
	for k, v in pairs(statsPrefixConf) do
		local tmp = {}
		table.insert(tmp, v)
		table.insert(tmp, host)
		table.insert(tmp, uri)
		StatsAllConf[k] = table.concat(tmp, "")
	end
	statsRun:incrStatsNumCache(ngx_shared['statsAll'],StatsAllConf)
end


-- 正则匹配统计
local request_method = ngx.var.request_method
local body

if request_method ~= 'GET' and request_method ~= 'DELETE'  
	and request_method ~= 'HEAD' and request_method ~= 'OPTIONS' then

	body = ngx.var.request_body
	if body ~= nil then
		--  body + uri
		local tmp = {}
		table.insert(tmp, uri)
		table.insert(tmp, body)
		body = table.concat(tmp, "")
	else
		-- uri
		body = uri	
	end
else
	body = uri
end

-- 获取正则特殊定制统计
for i, v in ipairs(statsMatchConf) do
	local m = ngxmatch(body, v['match'],"o")
    if m then 
        --ngx.say(m[0])
        --statsRun:incrStatsNumCache(ngx_shared['statsMatch'],m[0])
    end
end
