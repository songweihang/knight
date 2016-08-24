local redis = require "apps.lib.redis"

local handler

--第一个参数为premature
function handler(premature, params)
    local red = redis:new()
    
    local cjson = require('cjson.safe')
    local jencode = cjson.encode
    local stats = require "apps.lib.stats"
    local stats_center = stats:new()
    local keys = stats_center:read_key_lists('match')

	--递归
	local ok, err = ngx.timer.at(5, handler, "params-data")
	ngx.log(ngx.DEBUG, "ok:", ok, " err:", err)
end

--第一个nginx worker 执行redis操作
if ngx.worker.id() == 0 then
	local ok, err = ngx.timer.at(5, handler, "params-data")
	ngx.log(ngx.DEBUG, "ok:", ok, " err:", err)
end