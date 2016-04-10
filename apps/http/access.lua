local knightConfig 	= require "config.knight".run()
local systemConf 	= require "config.init"
local statsConf 	= systemConf.statsConf
local statsCache 	= ngx.shared.stats
local statsAllCache = ngx.shared.statsAll

local T = statsCache:get(statsConf.http_success_time)
--ngx.say(T)

function dump(o)
    if type(o) == 'table' then
        local s = ''
        for k,v in pairs(o) do
            if type(k) ~= 'number'
            then
                sk = '"'..k..'"'
            else
                sk =  k
            end
            s = s .. ', ' .. '['..sk..'] = ' .. dump(v)
        end
        s = string.sub(s, 3)
        return '{ ' .. s .. '} '
    else
        return tostring(o)
    end
end

--ngx.say(type(statsConf))

--
local stats = require "apps.lib.stats"

local ngxmatch         = ngx.re.match
local match 		   = string.match

--local body = ngx.var.request_body
local body = ngx.var.request_body
local regex = [[[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}\.[a-z A-Z]{1,10}]]

--local m = ngxmatch(body, regex)
--if m then ngx.say(m[0]) else ngx.say("not matched!") end


--ngx.say(ngx.var.request_time)

--ngx.exit(200)