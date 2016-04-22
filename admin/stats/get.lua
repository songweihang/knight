ngx.header["Content-Type"] = "text/html; charset=UTF-8"

local cjson             = require('cjson.safe')
-- 编码
local jencode           = cjson.encode

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

local stats = require "apps.lib.stats"
local stats_center = stats:new()
local keys = stats_center:read_key_lists('match')
ngx.print(jencode(keys))