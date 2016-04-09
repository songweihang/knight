local modulename = "configKnight"
local _M = {}

_M._VERSION = '0.1'

local systemConf        = require "config.init"
local path              = systemConf.knightJsonPath
local lockConf          = systemConf.lockConf

local lrucache          = require "resty.lrucache"
local knightConfCache   = lrucache.new(10)
--local knightConfCache   = ngx.shared.knightConf
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
    local knightJson, err = red:get("knight:appsConfig")

    if knightJson == nil then
        knightJson = readAll(path)
    end

    if knightJson ~= nil then
        local err, knightConfig = jdecode(knightJson)
        knightConfCache:set('appsConfig',knightConfig,120)
        red:set("knight:appsConfig",knightJson)
        return knightConfig
    end

    return nil
end

-- get knight.json
_M.run = function()
    local a,c = knightConfCache:get('appsConfig')
    local knightConfig = knightConfCache:get('appsConfig')
     
    if knightConfig then
        return knightConfig
    end
    -- cacahe lock
    local lock = resty_lock:new("knightConfLock",lockConf)
    local elapsed, err = lock:lock("knightConfLock")
    if not elapsed then
        -- lock failed acquired
    end

    local knightConfig = knightConfCache:get('appsConfig')
    
    if knightConfig then
        local ok, err = lock:unlock()
        if not ok then
            return nil,"failed to unlock: " .. err
        end
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