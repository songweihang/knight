local system_conf = require "config.init"
local limit_conf = require "config.limit"

local lim_conf,err = limit_conf.new('imit_conf')
if not lim_conf then
    ngx.log(ngx.ERR,"failed to instantiate a limit_conf object: ", err)
    return ngx.exit(500)
end

lim_conf:add(system_conf.limit)