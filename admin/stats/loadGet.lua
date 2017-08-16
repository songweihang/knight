ngx.header["Content-Type"] = "application/json;charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local cjson = require('cjson.safe')
-- 编码
local jencode = cjson.encode

local stats = require "apps.lib.stats"
local stats_center = stats:new()
local keys = stats_center:read_key_lists('match')
ngx.print(jencode(keys))