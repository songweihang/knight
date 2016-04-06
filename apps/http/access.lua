local appsConfig = require "config.app"
local conf = appsConfig.getAppsConfig()

local statsCache = ngx.shared.stats

local HTTP_ACCES_TOTAL = 'a:total'

local T = statsCache:get(HTTP_ACCES_TOTAL)
ngx.say(conf['http_stats_all'])
ngx.say(T)
--ngx.say(conf['redis']['host'])
--ngx.exit(200)