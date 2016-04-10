local modulename = "appsLibStats"

local _M = {}

_M._VERSION = '0.1'

local ngx 						= ngx
local systemConf 				= require "config.init"
local statsConf 				= systemConf.statsConf

local statsCache       			= ngx.shared.stats
local statsAllCache       		= ngx.shared.statsAll
local ngxmatch         			= ngx.re.match
local match 		   			= string.match

--[[
	获取当前url路径
    @return 
]]--
local uri = function()
	local uri = ngx.var.uri
	if uri == nil then
		return "_"
	end
	return uri
end

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

	cache:incr(conf.http_total,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if tonumber(ngx.var.status) >= ngx.HTTP_BAD_REQUEST then
		-- HTTP FAIL 
		cache:incr(conf.http_fail,1)
		cache:incr(conf.http_fail_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			cache:incr(conf.http_fail_upstream_time,ngx.var.upstream_response_time)
		end
	else
		cache:incr(conf.http_success_time,ngx.var.request_time)
		if ngx.var.upstream_response_time ~= nil then
			cache:incr(conf.http_success_upstream_time,ngx.var.upstream_response_time)
		end
	end
end

_M.init = function ()
	--Initial stats
	intStatsNumCache(statsCache,statsConf)
end

_M.run = function()
	-- http 请求总统计数据
	incrStatsNumCache(statsCache,statsConf)
	--_M.statsAll()
end

function _M.statsMatch()

	if ngx.var.request_method ~= 'GET' and ngx.var.request_method ~= 'DELETE'  
		and ngx.var.request_method ~= 'HEAD' and ngx.var.request_method ~= 'OPTIONS' then

		local body = ngx.var.request_body
		if body ~= nil then
			--  body + uri
			local tmp = {}
			table.insert(tmp, uri())
			table.insert(tmp, body)
			table.concat(tmp, "")
		else
			-- uri	
		end
	else
		-- uri
	end		
end

function _M.statsAll()
	local statsAllConf = _M.initStatsAll()
	incrStatsNumCache(statsAllCache,statsAllConf)
end

function _M.initStatsAll()
	
	local StatsAllConf = {}
	
	for k, v in pairs(statsConf) do
		local tmp = {}
		table.insert(tmp, v)
		table.insert(tmp, ngx.var.host)
		table.insert(tmp, uri())
		StatsAllConf[k] = table.concat(tmp, "")
	end

	-- 初始化统计值
	intStatsNumCache(statsAllCache,StatsAllConf)

	return StatsAllConf	
end

return _M