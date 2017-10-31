local _M    = {}
local mt    = { __index = _M }
_M._VERSION = "0.1"

local ip_parser = require "apps.lib.ip_parser"
local tonumber = tonumber

_M.new = function(self,policy)
    self.policy = policy
    return setmetatable(self, mt)
end

local isNULL = function(v)
    return v and v ~= ngx.null
end

_M.check = function(self)
    local policy = self.policy
    if type(policy) ~= 'table' then
        return nil
    end
    for i, v in pairs(policy) do
        if type(v['upstream']) ~= 'table' then
            return nil
        end
        if not v['upstream']['ip'] or not v['upstream']['port'] then
            return nil
        end
        if type(v['range']) ~= 'table' then
            return nil
        else
            v['range']['start'] = ip_parser.ip2long(v['range']['start'])
            v['range']['end'] = ip_parser.ip2long(v['range']['end'])
            if not tonumber(v['range']['start']) or not tonumber(v['range']['end']) then
                return nil
            end
            if tonumber(v['range']['start']) > tonumber(v['range']['end']) then
                return nil
            end
        end
        policy[i] = v
    end
    return policy
end


_M.reduction = function(self)
    local policy = self.policy
    if type(policy) ~= 'table' then
        return nil
    end
    for i, v in pairs(policy) do
        if type(v['upstream']) ~= 'table' then
            return nil
        end
        if not v['upstream']['ip'] or not v['upstream']['port'] then
            return nil
        end
        if type(v['range']) ~= 'table' then
            return nil
        else
            v['range']['start'] = ip_parser.long2ip(v['range']['start'])
            v['range']['end'] = ip_parser.long2ip(v['range']['end'])
        end
        policy[i] = v
    end
    return policy
end


_M.get_upstream = function(self, ip2long)
    local ip2long = tonumber(ip2long)
    if ip2long ~= nil then
        for _, v in pairs(self.policy) do 
            if type(v['range']) == 'table' and type(v['upstream']) == 'table' then
                if ip2long >= v['range']['start'] and ip2long <= v['range']['end'] then
                    --ngx.log(ngx.ERR, "backend: policy " , v['upstream']['ip'])
                    --ngx.log(ngx.ERR, "backend: ip " , ip2long)
                    return v['upstream']
                end
            end
        end
    end
    return nil
end

return _M