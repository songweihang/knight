-- Copyright (C) 2016-2016 WeiHang Song (Jakin)
local ngx_shared = ngx.shared
local assert = assert

local _M = {}

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

function _M.new(dict_name,limit)

    local dict = ngx_shared[dict_name]
    if not dict then
        return nil, "shared dict not found"
    end

    assert(limit.req.rate > 0 and limit.req.burst >0 and limit.conn.rate > 0 and limit.conn.burst >0 )

    local self = {
        dict = dict,
        limit = limit
    }
    return setmetatable(self, mt)
end

-- 获取限流设置
function _M.get(self)
    local dict = self.dict
    local limit = self.limit

    local ok, err = dict:add('req_rate',limit.req.rate)
    if ok then
        dict:add('req_burst',limit.req.burst)
        dict:add('conn_rate',limit.conn.rate)
        dict:add('conn_burst',limit.conn.burst)
        return limit
    else
        limit.req.rate = dict:get('req_rate')
        limit.req.burst = dict:get('req_burst')
        limit.conn.rate = dict:get('conn_rate')
        limit.conn.burst = dict:get('conn_burst')
        return limit
    end
end

function _M.set(self,limit)
    local dict = self.dict
    dict:set('req_rate',limit.req.rate)
    dict:set('req_burst',limit.req.burst)
    dict:set('conn_rate',limit.conn.rate)
    dict:set('conn_burst',limit.conn.burst)
end

return _M