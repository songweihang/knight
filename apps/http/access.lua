ngx.header["Content-Type"] = "text/html; charset=UTF-8"
local appsConfig = require "config.app"
err,conf = appsConfig.getAppsConfig()
ngx.say(conf['redis']['host'])
ngx.exit(200)