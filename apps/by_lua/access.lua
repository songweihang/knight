local denycc            = require "apps.lib.denycc"
local iputils           = require("resty.iputils")
local ip_parser         = require "apps.lib.ip_parser"
local ip                = ip_parser:get()
local system_conf       = require "config.init"
local ngxshared         = ngx.shared
local denycc_conf       = ngxshared.denycc_conf
local denycc_switch     = denycc_conf:get('denycc_switch') or system_conf.denycc_switch

if denycc_switch == 1 and not iputils.ip_in_cidrs(ip, whitelist) then
    denycc:denycc_run()
end