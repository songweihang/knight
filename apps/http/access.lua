local knightConfig 	= require "config.knight".run()
local systemConf 	= require "config.init"

local statsCache = ngx.shared.stats

local T = statsCache:get(systemConf.statsConf.http_success_time)

ngx.say(T)
--ngx.say(ngx.var.uri)
--ngx.say(ngx.var.request_body)

local ngxmatch         = ngx.re.match
local match 		   = string.match

--local body = ngx.var.request_body
local body = ngx.var.request_body
local regex = [[[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}]]
--local m = ngxmatch(body, regex)
--if m then ngx.say(m[0]) else ngx.say("not matched!") end


--ngx.say(ngx.var.request_time)

--ngx.exit(200)