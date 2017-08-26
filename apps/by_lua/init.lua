local system_conf    = require "config.init"
local whitelist_ips  = system_conf.whitelist_ips
local iputils        = require("resty.iputils")

iputils.enable_lrucache()
whitelist = iputils.parse_cidrs(whitelist_ips)