-- 屏蔽最大连接数
--if tonumber(ngx.var.connections_active) >= tonumber(10000) then
--    return ngx.exit(503)
--end

local remote_addr   = ngx.var.remote_addr
local system_conf   = require "config.init"
local ngx_shared    = ngx.shared

-- 获取限流设置
local limitConf = function(dict_name,limit)
    local dict = ngx_shared[dict_name]
    local ok, err = dict:add('req_rate',limit.req.rate)
    if ok then
        dict:add('req_burst',limit.req.burst)
        dict:add('conn_rate',limit.conn.rate)
        dict:add('conn_burst',limit.conn.burst)
        return limit
    else
        limit.req.rate = dict:get('req_rate')
        limit.req.burst = dict:get('req_burst')
        limit.conn.rate = dict:get('conn_rate')
        limit.conn.burst = dict:get('conn_burst')
        return limit
    end
end

local limit = limitConf('imit_conf',system_conf.limit)

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


if isWhitelist(whitelist_ips,remote_addr) then

    local limit_req = require "resty.limit.req"
    local lim, err = limit_req.new("my_limit_req_store", limit.req.rate, limit.req.burst)
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