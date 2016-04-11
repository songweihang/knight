local modulename = "appsLibStats"

local setmetatable 				= setmetatable
local ngxmatch         			= ngx.re.match
local match 		   			= string.match
local tonumber 					= tonumber
local assert 					= assert

local _M = {}

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }


function _M.new(self,status,uri,host,request_time,upstream_response_time)
    
    --assert(status >0 and uri >= 0 and request_time >0 and upstream_response_time > 0 and host >0 )

    local self = {
    	status = status,
        uri = uri,
        host = host,
        request_time = request_time,
        upstream_response_time = upstream_response_time,
    }

    return setmetatable(self, mt)
end

--[[
	初始化统计缓存
	@param cache ngx_shared 
    @param table conf
    @return 

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

_M.init = function ()
	--Initial stats
	intStatsNumCache(statsCache,statsPrefixConf)
end
]]--

--[[
	统计计数器
	@param cache ngx_shared 
    @param table conf
    @return 
]]--
function _M.incrStatsNumCache(self,cache,conf)

	local request_time = self.request_time
	local upstream_response_time = self.upstream_response_time
	local status = self.status

	-- 忽略 499 客户端链接中断的数据
	if tonumber(status) == 499 then
		return
	end
	
	cache:incr(conf.http_total,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if tonumber(status) >= 400 then
		-- HTTP FAIL 
		cache:incr(conf.http_fail,1)

		cache:incr(conf.http_fail_time,request_time)
		if upstream_response_time > 0 then
			cache:incr(conf.http_fail_upstream_time,upstream_response_time)
		end
	else
		cache:incr(conf.http_success_time,request_time)
		if upstream_response_time > 0 then
			cache:incr(conf.http_success_upstream_time,upstream_response_time)
		end
	end
	return
end

function _M.statsMatch(self)

	local ngx_var_uri = self.ngx_var_uri
	local request_method,body = ngx.var.request_method

	if request_method ~= 'GET' and request_method ~= 'DELETE'  
		and request_method ~= 'HEAD' and request_method ~= 'OPTIONS' then

		body = ngx.var.request_body
		if body ~= nil then
			--  body + uri
			local tmp = {}
			table.insert(tmp, ngx_var_uri)
			table.insert(tmp, body)
			table.concat(tmp, "")
		else
			-- uri	
		end
	else
		body = ngx_var_uri
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

function _M.statsAll(self)
	local statsAllConf = _M.initStatsAll()
	incrStatsNumCache(statsAllCache,statsAllConf)
end

function _M.initStatsAll(self)
	
	local ngx_var_uri 	= self.ngx_var_uri
	local ngx_var_host 	= self.ngx_var_host
	local StatsAllConf 	= {}
	
	for k, v in pairs(statsPrefixConf) do
		local tmp = {}
		table.insert(tmp, v)
		table.insert(tmp, ngx_var_host)
		table.insert(tmp, ngx_var_uri)
		StatsAllConf[k] = table.concat(tmp, "")
	end

	-- 初始化统计值
	intStatsNumCache(statsAllCache,StatsAllConf)

	return StatsAllConf	
end

return _M