ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local system_conf = require "config.init"
local limit_conf = require "config.limit"
local cjson = require('cjson.safe')
-- 编码
local jencode = cjson.encode
local ngx_shared = ngx.shared


local lim_conf,err = limit_conf.new(system_conf.limit.dict_name)
if not lim_conf then
    ngx.log(ngx.ERR,"failed to instantiate a limit_conf object: ", err)
    return ngx.exit(500)
end

local limit = lim_conf:get()
--获取当前并发连接数量
limit['online_connections_active'] = ngx.var.connections_active
--获取当前conn令牌数量 my_limit_conn_store
limit['limit_conn'] = ngx_shared[system_conf.limit.conn.dict_name]:get('limit_conn')

ngx.print(jencode(limit))