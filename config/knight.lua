local modulename = "configKnight"
local _M = {}

_M._VERSION = '0.1'

local systemConf        = require "config.init"
local path              = systemConf.knightJsonPath
local lockConf         = systemConf.lockConf

local knightConfCache   = ngx.shared.knightConf
local redis             = require "apps.lib.redis"
local resty_lock        = require "resty.lock"
--local json = require "json"
local cjson             = require('cjson.safe')

-- 编码
local jencode           = cjson.encode

--[[
    json decode
    @param string str
    @return table
]]--
local function jdecode(str)
    local data = nil
    _, err = pcall(function(str) return cjson.decode(str) end, str)
    return data, err
end

--[[
    Read file and bufferize content
    @param string file
    @return string
]]--
local function readAll(file)
    local f = io.open(file, "rb")
    local content = ""
    if f then
         content = f:read("*all")
        f:close()
    end
    return content
end

--[[
    load knight.json
    @return string
]]--
local function writeConfig()

    local red = redis:new()
    -- local knightJson, err = red:get("knight:appsConfig")

    if knightJson == nil then
        knightJson = readAll(path)
    end
    
    if knightJson ~= nil then
        local err, knightConfig = jdecode(knightJson)
        knightConfCache:set('appsConfig',knightJson,5)
        red:set("knight:appsConfig",knightJson)
        return knightConfig
    end

    return nil
end

-- get knight.json
_M.run = function()
    
    local knightJson,err = knightConfCache:get('appsConfig')
    if err then
        return nil,"failed to get key from shm: " .. err
    end   

    if knightJson then
        local err, knightConfig = jdecode(knightJson)
        return knightConfig
    end

    -- cacahe lock
    local lock = resty_lock:new("knightConfLock",lockConf)
    local elapsed, err = lock:lock("knightConfLock")
    if not elapsed then
        return nil,"failed to acquire the lock: " .. err
    end
    local knightJson,err = knightConfCache:get('appsConfig')
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

    local knightConfig = writeConfig()

    local ok, err = lock:unlock()
    if not ok then
        return nil,"failed to unlock: " .. err
    end

    return knightConfig

end

return _M