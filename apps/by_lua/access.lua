-- 屏蔽最大连接数
--if tonumber(ngx.var.connections_active) >= tonumber(10000) then
--    return ngx.exit(503)
--end
local require = require
local remote_addr = ngx.var.remote_addr
local system_conf = require "config.init"
local limit_conf = require "config.limit"

-- ip白名单设置
local whitelist_ips = system_conf.whitelist_ips
local isWhitelist = function(whitelist_ips,remote_addr)
    for i, ip in ipairs(whitelist_ips) do
        if remote_addr == ip then
            return false
        end
    end
    return true
end 

local lim_conf,err = limit_conf.new(system_conf.limit.dict_name)
if not lim_conf then
    ngx.log(ngx.ERR,"failed to instantiate a limit_conf object: ", err)
    return ngx.exit(500)
end

local limit = lim_conf:get()

if isWhitelist(whitelist_ips,remote_addr) then
    -- qps限流
    local limit_req = require "resty.limit.req"
    local lim, err = limit_req.new(system_conf.limit.req.dict_name, limit.req.rate, limit.req.burst)
    if not lim then
        ngx.log(ngx.ERR,"failed to instantiate a resty.limit.req object: ", err)
        return ngx.exit(500)
    end

    local delay, err = lim:incoming(remote_addr, true)
    if not delay then
        if err == "rejected" then
            ngx.log(ngx.ERR, "rejected: ", remote_addr)
            return ngx.exit(503)
        end
        ngx.log(ngx.ERR, "failed to limit req: ", err)
        return ngx.exit(500)
    end

    if delay > 0 then
        local excess = err
        ngx.sleep(delay)
    end
end

-- 连接并发限流
local limit_conn = require "resty.limit.conn"
local lim, err = limit_conn.new(system_conf.limit.conn.dict_name, limit.conn.rate, limit.conn.burst, 0.5)
if not lim then
    ngx.log(ngx.ERR,"failed to instantiate a resty.limit.conn object: ", err)
    return ngx.exit(500)
end
-- 单独限制网关入口流量
local key = 'limit_conn'
local delay, err = lim:incoming(key, true)
if not delay then
    if err == "rejected" then
        return ngx.exit(503)
    end
    ngx.log(ngx.ERR, "failed to limit req: ", err)
    return ngx.exit(500)
end

if lim:is_committed() then
    local ctx = ngx.ctx
    ctx.limit_conn = lim
    ctx.limit_conn_key = key
    ctx.limit_conn_delay = delay
end

local conn = err

if delay >= 0.001 then
    ngx.sleep(delay)
end