local denycc            = require "apps.lib.denycc"
local iputils           = require("resty.iputils")
local ip_parser         = require "apps.lib.ip_parser"
local ip                = ip_parser:get()
local system_conf       = require "config.init"
local ngxshared         = ngx.shared
local denycc_conf       = ngxshared.denycc_conf
local denycc_switch     = denycc_conf:get('denycc_switch') or system_conf.denycc_switch

local banned_ip_status = ngxshared.ip_blacklist_conf:get('banned_ip:' .. ip)
if banned_ip_status  then
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

if denycc_switch == 1 and not iputils.ip_in_cidrs(ip, whitelist) then
    denycc:denycc_run()
end