-- Copyright (C) 2016-2016 WeiHang Song (Jakin)
-- 使用redis保存异常请求链接

local redis = require "apps.lib.redis"
local tonumber = tonumber
local error = error
local ngxshared = ngx.shared
local ngxtimerat = ngx.timer.at
local log = ngx.log
local ERR = ngx.ERR
local ngxlocaltime = ngx.localtime()


local _M = {}

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

local handler

function handler(premature,status,host,uri,request_time,upstream_response_time)
    if premature then
        return
    end
    --写入文件日志
    log(ERR, ngxlocaltime .. " " .. status .. " " .. host .. uri .. " " .. request_time)

    -- 暂时屏蔽写入redis
    --[[

    local red = redis:new()
    local id,err = red:incr("log:error:uri:incr")
    if not id then
        error("failed to run id:" .. err)
        return
    end

    red:init_pipeline()
    red:lpush("log:error:uri:lists",id)
    red:hmset("log:info:" .. id, "created_at",ngxlocaltime,"status", status, "host", host,"uri",uri,"request_time",request_time,"upstream_response_time",upstream_response_time)
    local results, err = red:commit_pipeline()
    if not results then
        error("failed to commit the pipelined requests: " .. err)
        return
    end
    ]]
end


function _M.new(self,status,host,uri,request_time,upstream_response_time)
    local self = {
        status = tonumber(status) or 499,
        host = host,
        uri = uri or "-",
        request_time = request_time or 0,
        upstream_response_time = tonumber(upstream_response_time) or 0,
    }
    return setmetatable(self, mt)
end


function _M.run(self)
    if self.status >= 500 then
        -- 进行安全限制请求频率限制
        local limit,exptime,write_num = 60,60,0
        local ok, err = ngxshared["log_write_limit"]:add("log_write_limit_num",0,exptime)
        if not ok then
            write_num = ngxshared["log_write_limit"]:incr("log_write_limit_num",1)
        end
        if write_num <= limit then
            local ok, err = ngxtimerat(0, handler, self.status,self.host,self.uri,self.request_time,self.upstream_response_time)
        else
            --系统出现大量请求错误进行预警
            error("Forbidden write_num:" .. write_num)
        end
    end
end

return _M