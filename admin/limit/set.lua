ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local system_conf = require "config.init"
local limit_conf = require "config.limit"
local cjson = require('cjson.safe')
-- 编码
local jencode = cjson.encode
local args = ngx.req.get_uri_args()

local lim_conf,err = limit_conf.new(system_conf.limit.dict_name)
if not lim_conf then
    ngx.log(ngx.ERR,"failed to instantiate a limit_conf object: ", err)
    return ngx.exit(500)
end

if args['req_rate'] ~= nil then
    lim_conf:set_req_rate(args['req_rate'])
end

if args['req_burst'] ~= nil then
    lim_conf:set_req_burst(args['req_burst'])
end

if args['conn_rate'] ~= nil then
    lim_conf:set_conn_rate(args['conn_rate'])
end

if args['conn_burst'] ~= nil then
    lim_conf:set_conn_burst(args['conn_burst'])
end

ngx.print(jencode('OK'))