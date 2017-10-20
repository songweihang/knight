local balancer          = require "ngx.balancer"
local cjson             = require('cjson.safe')
local ngx_log           = ngx.log
local DEFAULT_UPSTREAM  = ngx.var.default_upstream or nil

local abtestcore = require "apps.lib.abtest.core"
local upstream = abtestcore:get_upstream()

local host,port = nil,nil
if not upstream then
    --  default upstream
    local ups = abtestcore:get_default_upstream()
    if not ups then
        ngx.exit(503)
        ngx.log(ngx.ERR, "DEFAULT UPSTREAM ERR: nil")
        return
    else
        ngx.log(ngx.ERR, "DEFAULT_UPSTREAM ups: ", cjson.encode(ups))
        host = ups['ip']
        port = ups['port']
    end
else
    host = upstream.ip
    port = upstream.port
end

local ok, err = balancer.set_current_peer(host, port)
if not ok then
    ngx.log(ngx.ERR, "failed to set the current peer: ", err)
    return ngx.exit(500)
end

-- local DEFAULT_UPSTREAM =  cjson.decode(DEFAULT_UPSTREAM)
-- ngx.log(ngx.ERR, "DEFAULT_UPSTREAM COUNT: ", #DEFAULT_UPSTREAM)