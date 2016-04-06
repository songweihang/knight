local modulename = "appsLibStats"

local _M = {}

_M._VERSION = '0.1'

local statsCache = ngx.shared.stats

local HTTP_ACCES_TOTAL = 'a:total'
local HTTP_ACCES_FAIL  = 'a:fail' 

_M.init = function ()
	--Initial stats
	statsCache:add(HTTP_ACCES_TOTAL,0)
	statsCache:add(HTTP_ACCES_FAIL,0)
	return 1
end

_M.run = function()
	statsCache:incr(HTTP_ACCES_TOTAL,1)
	if tonumber(ngx.var.status) >= 400 then
		-- HTTP FAIL 
		statsCache:incr(HTTP_ACCES_FAIL,1)
	end
end

return _M