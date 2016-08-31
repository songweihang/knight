-- Copyright (C) 2016-2016 WeiHang Song (Jakin)
local ngx_shared = ngx.shared
local assert = assert
local tonumber = tonumber

local _M = {}

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

function _M.new(dict_name)

    local dict = ngx_shared[dict_name]
    if not dict then
        return nil, "shared dict not found"
    end

    local self = {
        dict = dict
    }
    return setmetatable(self, mt)
end

function _M.add(self,limit)
    local dict = self.dict

    local ok, err = dict:add('req_rate',limit.req.rate)
    if ok then
        dict:add('req_burst',limit.req.burst)
        dict:add('req_switch',limit.req.switch)
        dict:add('conn_rate',limit.conn.rate)
        dict:add('conn_burst',limit.conn.burst)
        dict:add('conn_switch',limit.conn.switch)
    end
end

-- 获取限流设置
function _M.get(self)
    local dict = self.dict
    return {
            ['req'] = {
                ["rate"] = dict:get('req_rate'),
                ["burst"] = dict:get('req_burst'),
                ["switch"] = dict:get('req_switch')
            },
            ['conn'] = {
                ["rate"] = dict:get('conn_rate'),
                ["burst"] = dict:get('conn_burst'),
                ["switch"] = dict:get('conn_switch')
            }
    }
end

function _M.set_req_rate(self,rate)
    local dict = self.dict
    dict:set('req_rate',tonumber(rate))
end

function _M.set_conn_rate(self,rate)
    local dict = self.dict
    dict:set('conn_rate',tonumber(rate))
end

function _M.set_req_burst(self,burst)
    local dict = self.dict
    dict:set('req_burst',tonumber(burst))
end

function _M.set_conn_burst(self,burst)
    local dict = self.dict
    dict:set('conn_burst',tonumber(burst))
end

return _M