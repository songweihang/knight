ngx.header["Content-Type"] = "text/html; charset=UTF-8"
local appsConfig = require "config.app"
local conf = appsConfig.getAppsConfig()
local statusCache = ngx.shared.status
local status,err = statusCache:get("status")
--ngx.say(status)
--ngx.say(conf['redis']['host'])
--ngx.exit(200)