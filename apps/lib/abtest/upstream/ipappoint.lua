local _M    = {}
local mt    = { __index = _M }
_M._VERSION = "0.1"

local tonumber = tonumber

_M.new = function(self,policy)
    self.policy = policy
    return setmetatable(self, mt)
end

local isNULL = function(v)
    return v and v ~= ngx.null
end

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
            if not tonumber(v['range']['start']) or not tonumber(v['range']['end']) then
                return nil
            end
            if tonumber(v['range']['start']) > tonumber(v['range']['end']) then
                return nil
            end
        end
    end
    return true
end


_M.get_upstream = function(self, ip2long)
    local ip2long = tonumber(ip2long)
    if ip2long ~= nil then
        for _, v in pairs(self.policy) do 
            if type(v['range']) == 'table' and type(v['upstream']) == 'table' then
                if ip2long >= v['range']['start'] and ip2long <= v['range']['end'] then
                    ngx.log(ngx.ERR, "backend: policy " , v['upstream']['ip'])
                    ngx.log(ngx.ERR, "backend: ip " , ip2long)
                    return v['upstream']
                end
            end
        end
    end
    ngx.log(ngx.ERR, "backend: policy default")
    --return upstream
end

return _M