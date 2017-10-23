local _M    = {}
local mt    = { __index = _M }
_M._VERSION = "0.1"

local tonumber = tonumber
local ngx_log  = ngx.log

_M.new = function(self,policy)
    self.policy = policy
    return setmetatable(self, mt)
end

local isNULL = function(v)
    return v and v ~= ngx.null
end

--  policy is in format as {{upstream = '192.132.23.125', uidset ={ 214214, 23421,12421} }, {}}
_M.check = function(self)
    if type(self.policy) ~= 'table' then
        return nil
    end
    for _, v in pairs(self.policy) do
        if type(v['upstream']) ~= 'table' then
            return nil
        end
        if not v['upstream']['ip'] or not v['upstream']['port'] then
            return nil
        end
        if type(v['range']) ~= 'table' then
            return nil
        else    
            for _, vv in pairs(v['range']) do
                if not tonumber(vv) then
                    return nil
                end
            end
        end
    end
    return true
end


_M.get_upstream = function(self, uid)
    local uid = tonumber(uid)
    if uid ~= nil then
        for _, v in pairs(self.policy) do 
            if type(v['range']) == 'table' then
                for _, vv in pairs(v['range']) do
                    if tonumber(vv) == uid then
                        ngx_log(ngx.ERR, "backend: policy " , v['upstream']['ip'])
                        ngx_log(ngx.ERR, "backend: uid " , vv)
                        return v['upstream']
                    end
                end
            end
        end
    end
    return nil
end

return _M