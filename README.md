# knight
knight是基于 [openresty](https://openresty.org) 开发的集群api统计

###安装：
在nginx.conf添加,knight放路径可以根据实际情况进行调整

    lua_package_path "/home/wwwroot/servers/knight/?.lua;;";
    lua_code_cache on;
    lua_check_client_abort on;
    
    lua_shared_dict cache 5m;
    lua_shared_dict cache_locks 5m;
    
    lua_max_pending_timers 1024;
    lua_max_running_timers 256;
    include /home/wwwroot/servers/knight/config/lua.shared.dict;
    
    init_worker_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/init_worker.lua;
    log_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/log.lua;
        
    server
    {
        server_name knight.domian.cn;
        index index.html index.htm;
        
        location ~ ^/admin/([-_a-zA-Z0-9/]+) {
            set $path $1;
            content_by_lua_file '/home/wwwroot/qservers/knight/admin/$path.lua'; 
        }
            
        location = /favicon.ico {
                deny all;
                log_not_found off;
                access_log off;
        }
    }
    
###服务配置与使用：
knight/config/init.lua 中进行服务配置

    如果需要持久化保存api统计数据，或者需要集群化部署可以配置 _M.redisConf
    如果不需要持久化可以把可以把init_worker_by_lua_file 进行屏蔽即可
    _M.stats_match_conf 此配置你需要统计的api正则详细可以参考代码中的例子
    
### License

[MIT](./LICENSE)    