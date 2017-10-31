# knight
knight是基于 [openresty](https://openresty.org) 开发的集群API统计、灰度发布、CC防御模块

1、自定义规则进行API统计(运行次数、成功率、运行时间、流量)

2、支持UID以及IP灰度发布

3、支持简单IP频率限制以及IP封禁

4、所有操作均采用api进行操作，无需重启nginx

5、支持集群化

### 配置
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

    upstream backend {
        server 0.0.0.1;   # just an invalid address as a place holder
        balancer_by_lua_file /home/wwwroot/servers/knight/apps/by_lua/balancer.lua;
        keepalive 500;  # connection pool
    }  

    server
    {
        server_name knight.domian.cn;
        index index.html index.htm;
        
        location ~ ^/admin/([-_a-zA-Z0-9/]+) {
            set $path $1;
            content_by_lua_file '/home/wwwroot/servers/knight/admin/$path.lua'; 
        }
    }

    server
    {
        server_name domain.host.cn;
        index index.html index.htm;
        #设置默认转发集群weight值越大转发概率越高，在没有通过API设置以及redis挂掉都会采用如下转发规则
        set $default_upstream '[{"ip": "127.0.0.1","port": 8081,"weight":10},{"ip": "127.0.0.1","port": 8082,"weight":5}]';
        location / {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Connection "";
            proxy_http_version 1.1;
            proxy_pass http://backend;
        }
    }
    
### 详细说明
[API统计](https://github.com/songweihang/knight/blob/master/ApiStatis.md)
[灰度发布](https://github.com/songweihang/ABTest/blob/master/README.md)
[CC防御模块](https://github.com/songweihang/knight/blob/master/CC.md)

### License

MIT    