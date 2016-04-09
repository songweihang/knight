local knightConfig 	= require "config.knight".run()
local systemConf 	= require "config.init"
local statsConf 	= systemConf.statsConf
local statsCache 	= ngx.shared.stats
local statsAllCache = ngx.shared.statsAll

local T = statsCache:get(statsConf.http_success_time)

--ngx.say(type(statsConf))

--ngx.say(ngx.var.request_body)
--ngx.say(T)

local uri = ngx.var.uri
if uri == nil then
	return
end

local stats = require "apps.lib.stats"
local conf = stats.initStatsAll(statsConf,uri)
--ngx.say(conf.http_total)
--ngx.say(statsAllCache:get(conf.http_total))

local ngxmatch         = ngx.re.match
local match 		   = string.match

--local body = ngx.var.request_body
local body = ngx.var.request_body
local regex = [[[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}]]

--local m = ngxmatch(body, regex)
--if m then ngx.say(m[0]) else ngx.say("not matched!") end


--ngx.say(ngx.var.request_time)

--ngx.exit(200)