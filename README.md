# knight
knight是基于 [openresty](https://openresty.org) 开发的集群api统计

### 安装
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
    
### 服务配置与使用

knight/config/init.lua 中进行服务配置

    如果需要持久化保存api统计数据，或者需要集群化部署可以配置 _M.redisConf的Redis服务地址
    如果不需要持久化可以把可以屏蔽 init_worker_by_lua_file
    你需要统计的api 则需要配置 _M.stats_match_conf 中的正则表达式
    
### 数据获取
    
    开启集群 获取数据方式 GET http://knight.domian.cn/admin/stats/get
    未开启   GET http://knight.domian.cn/admin/stats/loadGet
    
### 数据格式
    
    [{"success_time_avg":"3.52","flow_all":"219311.76","fail":45542,"flow_avg":"0.41","success_upstream_time":1314682.3707269,"fail_upstream_time_avg":"3.52","fail_time_avg":"5.46","success_ratio":"99.992","fail_time":248548.99999993,"success_time":1917575642.5463,"total":544744593,"success_upstream_time_avg":"2.41","api":"knightapi-\/v1\/answer\/"}]
    
    
### License

[MIT](./LICENSE)    