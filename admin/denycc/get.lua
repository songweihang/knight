ngx.header["Content-Type"] = "application/json;charset=UTF-8"

local cjson       = require('cjson.safe')
local jencode     = cjson.encode
local system_conf = require "config.init"
local denycc_rate_conf  = system_conf.denycc_rate_conf
local ngxshared   = ngx.shared
local denycc_conf = ngxshared.denycc_conf

local config = {
    ["denycc_switch"] = denycc_conf:get('denycc_switch') or system_conf.denycc_switch,
    ["denycc_rate_request"] = denycc_conf:get('denycc_rate_request') or denycc_rate_conf.request,
    ["denycc_rate_ts"] = denycc_conf:get('denycc_rate_ts') or denycc_rate_conf.ts,
    ["whitelist_ips"] = system_conf.whitelist_ips
}

ngx.print(jencode(config))