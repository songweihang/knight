local knightConfig 	   = require "config.knight".run()
local systemConf 	   = require "config.init"
local statsPrefixConf  = systemConf.statsPrefixConf
local statsMatchConf   = systemConf.statsMatchConf
local ngx_shared       = ngx.shared
--[[
if jit then 
    ngx.say(jit.version) 
else 
    ngx.say(_VERSION) 
end
]]--
local keys = ngx_shared['stats_match_keys']:get_keys(0)
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

-- 过滤nginx无法处理请求

ngx.say(dump(keys))
local keys = ngx_shared['stats_match_success_time']:get('api.model.getxxx')
ngx.say(dump(keys))

--local stats = require "apps.lib.stats"
--local a = stats:new(1,2,3,4,5)
--ngx.say(dump(a))
--a:incrStatsNumCache(statsCache,statsPrefixConf)