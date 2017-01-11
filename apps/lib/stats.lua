-- Copyright (C) 2016-2016 WeiHang Song (Jakin)
-- 此库需要在log_by_lua阶段中执行，主要实现获取HTTP请求数据统计

local setmetatable    = setmetatable
local ngxshared       = ngx.shared
local ngxfind         = ngx.re.find
local sub             = string.sub
local strformat       = string.format
local tonumber        = tonumber
local error           = error
local SHARED_NAMES    = {}

SHARED_NAMES['all'] = {
	["lock"] = "stats_all_key_lock",
	["keys"] = "stats_all_keys",
	["total"] = "stats_all_total",
	["fail"] = "stats_all_fail",
	["success_time"] = "stats_all_success_time",
	["fail_time"] = "stats_all_fail_time",
	["success_upstream_time"] = "stats_all_success_upstream_time",
	["fail_upstream_time"] = "stats_all_fail_upstream_time",
	["bytes_sent"] = "stats_all_bytes_sent",
}

SHARED_NAMES['match'] = {
	["lock"] = "stats_match_key_lock",
	["keys"] = "stats_match_keys",
	["total"] = "stats_match_total",
	["fail"] = "stats_match_fail",
	["success_time"] = "stats_match_success_time",
	["fail_time"] = "stats_match_fail_time",
	["success_upstream_time"] = "stats_match_success_upstream_time",
	["fail_upstream_time"] = "stats_match_fail_upstream_time",
	["bytes_sent"] = "stats_match_bytes_sent"
}

local _M = {}

local _M = { _VERSION = '0.03' }

local mt = { __index = _M }


local function _add_num_cache(key,rule)
	local shareddict = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	local ok, err = ngxshared[shareddict.lock]:add(key,true)
	if ok then
		ngxshared[shareddict.keys]:add(key,0)
		ngxshared[shareddict.total]:add(key,0)
		ngxshared[shareddict.fail]:add(key,0)
		ngxshared[shareddict.success_time]:add(key,0)
		ngxshared[shareddict.fail_time]:add(key,0)
		ngxshared[shareddict.success_upstream_time]:add(key,0)
		ngxshared[shareddict.fail_upstream_time]:add(key,0)
		ngxshared[shareddict.bytes_sent]:add(key,0)
	end
end


local function _flush_key(key,rule)
	local shareddict = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	local total = ngxshared[shareddict.keys]:delete(key)
	local total = ngxshared[shareddict.total]:delete(key)
	local fail = ngxshared[shareddict.fail]:delete(key)
	local success_time = ngxshared[shareddict.success_time]:delete(key)
	local fail_time = ngxshared[shareddict.fail_time]:delete(key)
	local success_upstream_time = ngxshared[shareddict.success_upstream_time]:delete(key)
	local fail_upstream_time = ngxshared[shareddict.fail_upstream_time]:delete(key)
	local bytes_sent = ngxshared[shareddict.bytes_sent]:delete(key)
end


function _M.new(self,uri,status,request_time,upstream_response_time,bytes_sent)
	--assert(status >0 and uri >= 0 and request_time >0 and upstream_response_time > 0 and host >0 )
	local self = {
		uri = uri or "-",
		status = tonumber(status) or 499,
		request_time = request_time or 0,
		upstream_response_time = tonumber(upstream_response_time) or 0,
		bytes_sent = tonumber(bytes_sent) or 0,
	}
	return setmetatable(self, mt)
end


local function incr(self,key,rule)
	local shareddict = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	local request_time = self.request_time
	local upstream_response_time = self.upstream_response_time
	local status = self.status
	local bytes_sent = self.bytes_sent
	-- 忽略 499 客户端链接中断的数据 TODO 400 405 408 414 494  501
	if status == 499 then
		return
	end

	-- 初始化计数器
	_add_num_cache(key,rule)
	
	ngxshared[shareddict.total]:incr(key,1)
	ngxshared[shareddict.bytes_sent]:incr(key,bytes_sent)
	-- ngx.HTTP_INTERNAL_SERVER_ERROR
	if status >= 400 then
		-- HTTP FAIL 
		ngxshared[shareddict.fail]:incr(key,1)

		ngxshared[shareddict.fail_time]:incr(key,request_time)
		if upstream_response_time > 0 then
			ngxshared[shareddict.fail_upstream_time]:incr(key,upstream_response_time)
		end
	else
		ngxshared[shareddict.success_time]:incr(key,request_time)
		if upstream_response_time ~= 0 and upstream_response_time ~= nil then
			ngxshared[shareddict.success_upstream_time]:incr(key,upstream_response_time)
		end
	end
end

_M.incr = incr


function _M.read_body(self)
	local uri = self.uri
	local request_method,body = ngx.var.request_method,''

	if request_method == 'GET' or request_method == 'DELETE'  
		or request_method == 'HEAD' or request_method == 'OPTIONS' then

		local args = ngx.var.args
		if args ~= nil then
			body = uri .. '?' .. args	
		else
			body = uri
		end
	else
		local request_body = ngx.var.request_body
		if request_body ~= nil then
			body = uri .. '?' .. request_body
		else
			body = uri
		end
	end
	return body
end


function _M.incr_match(self,body,match)
	-- 获取正则特殊定制统计
	local from,to,err = ngxfind(body, match,"jo")
	if from then 
	    local api = sub(body,from,to)
	    incr(self,api,"match")
	end
end


local function read_key_result(self,key,rule)
	local shareddict = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	local total = ngxshared[shareddict.total]:get(key)
	local fail = ngxshared[shareddict.fail]:get(key)
	local success_time = ngxshared[shareddict.success_time]:get(key)
	local fail_time = ngxshared[shareddict.fail_time]:get(key)
	local success_upstream_time = ngxshared[shareddict.success_upstream_time]:get(key)
	local fail_upstream_time = ngxshared[shareddict.fail_upstream_time]:get(key)
	local bytes_sent = ngxshared[shareddict.bytes_sent]:get(key)

	if total == nil or fail == nil or success_time == nil or fail_time == nil 
		or success_upstream_time == nil or fail_upstream_time == nil or bytes_sent == nil then

		--删除异常数据
		_flush_key(key,rule)
		return nil
	else
		--成功请求次数
		local success_total = total-fail
		-- 接口成功率
		local success_ratio = strformat("%.3f",success_total/total*100)
		local success_time_avg,success_upstream_time_avg,fail_time_avg,fail_upstream_time_avg = '0.00','0.00','0.00','0.00'
		if success_total > 0 then
			-- 成功接口请求平均时间
			success_time_avg = strformat("%.2f",success_time/success_total*1000)
			-- 成功接口上游请求时间
			success_upstream_time_avg = strformat("%.2f",success_upstream_time/success_total*1000)
		end

		if fail > 0 then
			-- 失败接口请求平均时间
			fail_time_avg = strformat("%.2f",fail_time/fail*1000)
			-- 失败接口上游请求时间
			fail_upstream_time_avg = strformat("%.2f",fail_upstream_time/fail*1000)
		end

		local flow_all = strformat("%.2f",bytes_sent/1024/1024)
		local flow_avg = strformat("%.2f",bytes_sent/1024/total)

		return {
			["api"] = key,
			["total"] = total,
			["fail"] = fail,
			["success_ratio"] = success_ratio,
			["success_time"] = success_time,
			["success_upstream_time"] = success_upstream_time,
			["success_time_avg"] = success_time_avg,
			["success_upstream_time_avg"] = success_upstream_time_avg,
			["fail_time_avg"] = fail_time_avg,
			["fail_upstream_time_avg"] = fail_upstream_time_avg,
			["flow_all"] = flow_all,
			["flow_avg"] = flow_avg
		}
	end
end

_M.read_key_result = read_key_result


-- 调用此方法需要非常小心 会驻塞所有访问字典的nginx worker
function _M.read_key_lists(self,rule)
	local tableinsert = table.insert
	local shareddict  = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	local keys,lists = ngxshared[shareddict.keys]:get_keys(0),{}

	for i, key in ipairs(keys) do
		local ratio = read_key_result(self,key,rule)
		if ratio ~= nil then
			tableinsert(lists,ratio)
		end
	end

	return lists
end


function _M.flush_all(self,rule)
	local shareddict  = SHARED_NAMES[rule]

	if shareddict == nil then
		error('not rule initialized')
	end

	ngxshared[shareddict.lock]:flush_all()
	ngxshared[shareddict.keys]:flush_all()
	ngxshared[shareddict.total]:flush_all()
	ngxshared[shareddict.fail]:flush_all()
	ngxshared[shareddict.success_time]:flush_all()
	ngxshared[shareddict.fail_time]:flush_all()
	ngxshared[shareddict.success_upstream_time]:flush_all()
	ngxshared[shareddict.fail_upstream_time]:flush_all()
end

return _M