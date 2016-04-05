local modulename = "configApp"
local _M = {}

_M._VERSION = '0.1'

local redis = require "apps.lib.redis"
local resty_lock = require "resty.lock"
--local json = require "json"
local cjson= require('cjson.safe')

-- 编码
local jencode   = cjson.encode

-- 解码
local function jdecode(str)
    local data = nil
    _, err = pcall(function(str) return cjson.decode(str) end, str)
    return data, err
end

local path = "/Users/apple/Jakin/knight/config/knight.json"
local appsConfigCache = ngx.shared.appsConfig

--load knight.json
function _M.setAppsConfig()

    local red = redis:new()
    local knightJson, err = red:get("knight:appsConfig")

    if knightJson == nil then

        local file = io.open(path, "r")

        if file == nil then
            return nil
        end

        knightJson = file:read("*all");
        file:close();
    end
    
    if knightJson ~= nil then

        local err, knightConfig = jdecode(knightJson)
        appsConfigCache:set('appsConfig',knightJson,5)
        red:set("knight:appsConfig",knightJson)
        return knightConfig
    end

    return nil
end

-- get knight.json
function _M.getAppsConfig()
    
    local knightJson,err = appsConfigCache:get('appsConfig')
    if err then
        return nil,"failed to get key from shm: " .. err
    end   

    if knightJson then
        local err, knightConfig = jdecode(knightJson)
        return knightConfig
    end

    -- cacahe lock
    local lock = resty_lock:new("ConfigLocks")
    local elapsed, err = lock:lock("ConfigLocks")
    if not elapsed then
        return nil,"failed to acquire the lock: " .. err
    end
    local knightJson,err = appsConfigCache:get('appsConfig')
    if err then
        return nil,"failed to get key from shm: " .. err
    end 

    if knightJson then
        local ok, err = lock:unlock()
        if not ok then
            return nil,"failed to unlock: " .. err
        end
        local err, knightConfig = jdecode(knightJson)
        return knightConfig
    end

    local knightConfig = _M.setAppsConfig()

    local ok, err = lock:unlock()
    if not ok then
        return nil,"failed to unlock: " .. err
    end

    return knightConfig

end

return _M