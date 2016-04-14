local modulename = "appsLibStats"

local setmetatable 				= setmetatable
local assert 					= assert

local _M = {}

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }


function _M.new(self,status,request_time,upstream_response_time)
    
    --assert(status >0 and uri >= 0 and request_time >0 and upstream_response_time > 0 and host >0 )

    local self = {
    	status = status,
        request_time = request_time,
        upstream_response_time = upstream_response_time,
    }

    return setmetatable(self, mt)
end

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
function _M.incrStatsNumCache(self,cache,conf)

	local request_time = self.request_time
	local upstream_response_time = self.upstream_response_time
	local status = self.status

	-- 忽略 499 客户端链接中断的数据
	if status == 499 then
		return
	end
	
	-- 初始化计数器
	intStatsNumCache(cache,conf)

	cache:incr(conf.http_total,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if status >= 400 then
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



return _M