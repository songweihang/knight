local redis = require "apps.lib.redis"

local handler

--第一个参数为premature
function handler(premature, params)
	local red = redis:new()
	red:set(ngx.now(), ngx.now())
	ngx.log(ngx.DEBUG, "ngx.time.at:", ngx.now(), " premature:", url, " params:", url2)
	--递归
	
	local ok, err = ngx.timer.at(1, handler, "params-data")
	ngx.log(ngx.DEBUG, "ok:", ok, " err:", err)
end

--第一个nginx worker 执行redis操作
if ngx.worker.id() == 1 then
	local ok, err = ngx.timer.at(1, handler, "params-data")
	ngx.log(ngx.DEBUG, "ok:", ok, " err:", err)
end

