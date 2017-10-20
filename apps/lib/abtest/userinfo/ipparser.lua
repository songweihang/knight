
local _M = {
    _VERSION = '0.01'
}

local ip_parser = require "apps.lib.ip_parser"

_M.get = function()
    local ip2long = ip_parser:get_ip2long()
    return ip2long
end


return _M