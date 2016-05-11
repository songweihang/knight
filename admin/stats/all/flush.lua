ngx.header["Content-Type"] = "text/html; charset=UTF-8"

local stats = require "apps.lib.stats"
local stats_center = stats:new()
local keys = stats_center:flush_all('all')
ngx.print('OK')