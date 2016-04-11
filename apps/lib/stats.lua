local modulename = "appsLibStats"

local _M = {}

_M._VERSION = '0.1'

local ngx_var 					= ngx.var
local systemConf 				= require "config.init"
local statsPrefixConf 			= systemConf.statsPrefixConf
local statsMatchConf			= systemConf.statsMatchConf
local statsAllSwitchConf		= systemConf.statsAllSwitchConf

-- ngx.shared.DICT 
local statsCache       			= ngx.shared.stats
local statsAllCache       		= ngx.shared.statsAll
local statsMatchCache        	= ngx.shared.statsMatch

local ngxmatch         			= ngx.re.match
local match 		   			= string.match

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

--[[
	统计计数器
	@param cache ngx_shared 
    @param table conf
    @return 
]]--
local function incrStatsNumCache(cache,conf)

	if tonumber(ngx_var.status) == 499 then
		return
	end
	
	cache:incr(conf.http_total,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if tonumber(ngx_var.status) >= 400 then
		-- HTTP FAIL 
		cache:incr(conf.http_fail,1)

		cache:incr(conf.http_fail_time,ngx_var.request_time)
		if ngx_var.upstream_response_time ~= nil then
			cache:incr(conf.http_fail_upstream_time,ngx_var.upstream_response_time)
		end
	else
		cache:incr(conf.http_success_time,ngx_var.request_time)
		if ngx_var.upstream_response_time ~= nil then
			cache:incr(conf.http_success_upstream_time,ngx_var.upstream_response_time)
		end
	end
end

_M.init = function ()
	--Initial stats
	intStatsNumCache(statsCache,statsPrefixConf)
end

_M.run = function()
	-- http 请求总统计数据
	incrStatsNumCache(statsCache,statsPrefixConf)
end

function _M.statsMatch()

	local body,method = '',ngx_var.request_method

	if method ~= 'GET' and method ~= 'DELETE'  
		and method ~= 'HEAD' and method ~= 'OPTIONS' then

		body = ngx_var.request_body
		if body ~= nil then
			--  body + uri
			local tmp = {}
			table.insert(tmp, ngx_var.uri)
			table.insert(tmp, body)
			table.concat(tmp, "")
		else
			-- uri	
		end
	else
		body = ngx_var.uri
	end

	-- 获取正则特殊定制统计
	for i, v in ipairs(statsMatchConf) do
    	local m = ngxmatch(body, v['match'],"o")
	    if m then 
	        --ngx.say(m[0])
	        --intStatsNumCache(statsMatchCache,conf)
	    else 
	        --ngx.say("not matched!") 
	    end
	end		
end

function _M.statsAll()
	local statsAllConf = _M.initStatsAll()
	incrStatsNumCache(statsAllCache,statsAllConf)
end

function _M.initStatsAll()
	
	local StatsAllConf = {}
	
	for k, v in pairs(statsPrefixConf) do
		local tmp = {}
		table.insert(tmp, v)
		table.insert(tmp, ngx_var.host)
		table.insert(tmp, ngx_var.uri)
		StatsAllConf[k] = table.concat(tmp, "")
	end

	-- 初始化统计值
	intStatsNumCache(statsAllCache,StatsAllConf)

	return StatsAllConf	
end

return _M