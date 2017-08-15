local stats       = require "apps.lib.stats"
local system_conf = require "config.init"
--第一个nginx worker 执行redis操作
if ngx.worker.id() == 1 then
    local ok, err = stats:timer_at_redis('match',system_conf.redisConf)
    ngx.log(ngx.ERR, "timer_at run worker:",ngx.worker.id())
end