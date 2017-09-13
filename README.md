# knight
knight是基于 [openresty](https://openresty.org) 开发的集群API统计、CC防御模块

### 安装
如下是nginx.conf的最小配置 实际knight放路径可以根据实际情况进行调整

    lua_package_path "/home/wwwroot/servers/knight/?.lua;;";
    lua_code_cache on;
    lua_check_client_abort on;
    
    lua_max_pending_timers 1024;
    lua_max_running_timers 256;
    include /home/wwwroot/servers/knight/config/lua.shared.dict;
    
    init_worker_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/init_worker.lua;
    init_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/init.lua;
    access_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/access.lua;
    log_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/log.lua;
        
    server
    {
        server_name knight.domian.cn;
        index index.html index.htm;
        
        location ~ ^/admin/([-_a-zA-Z0-9/]+) {
            set $path $1;
            content_by_lua_file '/home/wwwroot/servers/knight/admin/$path.lua'; 
        }
            
        location = /favicon.ico {
                deny all;
                log_not_found off;
                access_log off;
        }
    }
    
### 服务配置与使用

knight/config/init.lua 中进行服务配置

    如果需要持久化数据API或者集群化部署可以配置 _M.redisConf的Redis服务地址
    如果不需要持久化可以把可以屏蔽 init_worker_by_lua_file 默认会采用nginx共享内存实现统计
    需要统计的API规则可以在_M.stats_match_conf中使用正则表达式进行配置
    
### 数据获取
    
    开启集群 获取数据方式 GET http://knight.domian.cn/admin/stats/get
    未开启   GET http://knight.domian.cn/admin/stats/loadGet
    
### 数据格式
    
    [{"success_time_avg":"3.52","flow_all":"219311.76","fail":45542,"flow_avg":"0.41","success_upstream_time":1314682.3707269,"fail_upstream_time_avg":"3.52","fail_time_avg":"5.46","success_ratio":"99.992","fail_time":248548.99999993,"success_time":1917575642.5463,"total":544744593,"success_upstream_time_avg":"2.41","api":"knightapi-\/v1\/answer\/"}]

### 数据收集生成图形报表
![](https://raw.githubusercontent.com/songweihang/ngx-lua-knight/master/doc/img/%E6%9F%A5%E8%AF%A2%E5%BD%93%E6%97%A5api%E6%8E%A5%E5%8F%A3%E6%89%A7%E8%A1%8C%E6%83%85%E5%86%B5.png)

![](https://github.com/songweihang/ngx-lua-knight/blob/master/doc/img/%E7%BD%91%E5%85%B3%E6%9C%8D%E5%8A%A1%E6%B5%81%E9%87%8F%E8%B5%B0%E5%8A%BF%E5%9B%BE.png?raw=true)

### 如何使用cc防御模块
cc模块默认关闭 可以通过接口进行开启服务

    获取cc防御配置 GET http://knight.domian.cn/admin/denycc/get
    修改cc防御配置 GET http://knight.domian.cn/admin/denycc/store?denycc_switch=0&denycc_rate_request=501&denycc_rate_ts=60
    denycc_switch 0关闭 1开启
    denycc_rate_ts cc统计周期默认60秒不建议修改  
    denycc_rate_request denycc_rate_ts时间内单ip执行最大次数
    可以在knight/config/init.lua中whitelist_ips配置cc白名单，whitelist_ips会自动绕开cc限制，默认配置所有内网地址均加入白名单


### License

MIT    