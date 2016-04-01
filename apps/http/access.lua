ngx.header["Content-Type"] = "text/html; charset=UTF-8"
local json = require "config.app"
err,conf = json.load_json_config()
ngx.say(conf['redis']['host'])
ngx.exit(200)