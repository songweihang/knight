local ngxshared = ngx.shared
local function dump(o)
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

--local keys = ngxshared['stats_match_keys']:get_keys(0)
--local keysall = ngxshared['stats_all_keys']:get_keys(0)

local stats = require "apps.lib.stats"
local stats_center = stats:new()
local keys = stats_center:read_key_lists('match')
local total,fail,success_time,fail_time,success_upstream_time,fail_upstream_time = stats_center:read_key_result('api.model.getxxx','match')
-- 过滤nginx无法处理请求
--ngx.say(dump(keysall))
--ngx.say(dump(keys))
--ngx.say(total)

--local stats = require "apps.lib.stats"
--local a = stats:new(1,2,3,4,5)
--ngx.say(dump(a))
--a:incrStatsNumCache(statsCache,statsPrefixConf)


--[[
if jit then 
    ngx.say(jit.version) 
else 
    ngx.say(_VERSION) 
end
]]--