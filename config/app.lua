local modulename = "configApp"
local _M = {}

_M._VERSION = '0.1'

local json = require "json"
-- 编码
local jencode   = json.encode   
-- 解码
local function jdecode(str)
    local data = nil
    _, err = pcall(function(str) return json.decode(str) end, str)
    return data, err
end

local path = "/Users/apple/Jakin/knight/config/knight.json"
local appsConfig = ngx.shared.appsConfig


--load knight.json
function _M.setAppsConfig()

	local file = io.open(path, "r")

	if file == nil then
		return nil
    end

    local knightJson = file:read("*all");
    file:close();
    
    if knightJson ~= nil then
        appsConfig:set('appsConfig',knightJson)       
    end
	
    return jdecode(knightJson)
end

-- get knight.json
function _M.getAppsConfig()
    return jdecode(appsConfig:get('appsConfig'))
end

return _M