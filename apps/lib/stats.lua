-- Copyright (C) 2016-2016 WeiHang Song (Jakin)
-- 此库需要在log_by_lua阶段中执行，主要实现获取HTTP请求数据统计

local setmetatable 				= setmetatable
local assert 					= assert
local ngx_shared 				= ngx.shared
local shared_names 				= {}

shared_names['all'] = {
	["keys"] = "stats_all_keys",
	["total"] = "stats_all_total",
	["fail"] = "stats_all_fail",
	["success_time"] = "stats_all_success_time",
	["fail_time"] = "stats_all_fail_time",
	["success_upstream_time"] = "stats_all_success_upstream_time",
	["fail_upstream_time"] = "stats_all_fail_upstream_time"
}

shared_names['match'] = {
	["keys"] = "stats_match_keys",
	["total"] = "stats_match_total",
	["fail"] = "stats_match_fail",
	["success_time"] = "stats_match_success_time",
	["fail_time"] = "stats_match_fail_time",
	["success_upstream_time"] = "stats_match_success_upstream_time",
	["fail_upstream_time"] = "stats_match_fail_upstream_time"
}

local _M = {}

local _M = { _VERSION = '0.02' }

local mt = { __index = _M }


function _M.new(self,status,request_time,upstream_response_time)
    
    --assert(status >0 and uri >= 0 and request_time >0 and upstream_response_time > 0 and host >0 )
    local self = {
    	status = status or 499,
        request_time = request_time or 0,
        upstream_response_time = upstream_response_time or 0,
    }

    return setmetatable(self, mt)
end


local function add_stats_num_cache(keys,rule)

	local sharedconf = shared_names[rule]

	local ok, err = ngx_shared[sharedconf.keys]:add(keys,0)
	if ok then
		ngx_shared[sharedconf.total]:add(keys,0)
		ngx_shared[sharedconf.fail]:add(keys,0)
		ngx_shared[sharedconf.success_time]:add(keys,0)
		ngx_shared[sharedconf.fail_time]:add(keys,0)
		ngx_shared[sharedconf.success_upstream_time]:add(keys,0)
		ngx_shared[sharedconf.fail_upstream_time]:add(keys,0)
	end
end


function _M.incr_stats_num_cache(self,keys,rule)

	local sharedconf = shared_names[rule]

	local request_time = self.request_time
	local upstream_response_time = self.upstream_response_time
	local status = self.status

	-- 忽略 499 客户端链接中断的数据 TODO 400 405 408 414 494  501
	if status == 499 then
		return
	end
	
	-- 初始化计数器
	add_stats_num_cache(keys,rule)

	ngx_shared[sharedconf.total]:incr(keys,1)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if status >= 400 then
		-- HTTP FAIL 
		ngx_shared[sharedconf.fail]:incr(keys,1)

		ngx_shared[sharedconf.fail_time]:incr(keys,request_time)
		if upstream_response_time > 0 then
			ngx_shared[sharedconf.fail_upstream_time]:incr(keys,upstream_response_time)
		end
	else
		ngx_shared[sharedconf.success_time]:incr(keys,request_time)
		if upstream_response_time > 0 then
			ngx_shared[sharedconf.success_upstream_time]:incr(keys,upstream_response_time)
		end
	end
	return
end


function _M.request_data(self,uri)

	local request_method,body = ngx.var.request_method,''

	if request_method == 'GET' or request_method == 'DELETE'  
		or request_method == 'HEAD' or request_method == 'OPTIONS' then

		local args = ngx.var.args
		if args ~= nil then
			body = uri .. args	
		else
			body = uri
		end
	else
		local request_body = ngx.var.request_body
		if body ~= nil then
			body = uri .. request_body
		else
			body = uri
		end
	end
	return body
end

return _M