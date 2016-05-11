ngx.header["Content-Type"] = "text/html; charset=UTF-8"
ngx.header["Access-Control-Allow-Origin"] = "*"

local cjson             = require('cjson.safe')
-- 编码
local jencode           = cjson.encode

local stats = require "apps.lib.stats"
local stats_center = stats:new()
local keys = stats_center:read_key_lists('all')
ngx.print(jencode(keys))