local stats       = require "apps.lib.stats"
local system_conf = require "config.init"
local conf        = require "apps.lib.conf"

--第一个nginx worker 执行redis操作
if ngx.worker.id() == 1 then
    if system_conf.stats_redis_dump_switch then
        stats:timer_at_redis('match',system_conf.redisConf)
    end
    conf:timer_at_redis()
    ngx.log(ngx.ERR, "timer_at run worker:",ngx.worker.id())
end