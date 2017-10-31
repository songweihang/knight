### 服务配置与使用

knight/config/init.lua 服务配置说明
    
    -- redis 服务配置
    _M.redisConf = {
        ["uds"]      = nil,
        ["host"]     = '127.0.0.1',
        ["port"]     = '6379',
        ["poolsize"] = 2000,
        ["idletime"] = 90000, 
        ["timeout"]  = 1000,
        ["dbid"]     = 0,
        ["auth"]     = ''
    }

    -- 是否把API统计刷入REDIS中，如果集群nginx建议开启
    _M.stats_redis_dump_switch  = true
    -- 是否开启API统计
    _M.stats_match_switch  = true
    -- API统计正则规则
    _M.stats_match_conf = {
        {["host"]="b.domain.cn",["match"]="\\/api\\/v\\d+\\/[\\/a-zA-Z]+",["switch"]=true,["limit"]=0},
        {["host"]="a.domain.cn",["match"]="\\/v\\d+\\/[\\/a-zA-Z_-]+",["switch"]=true,["limit"]=0},
        {["host"]="c.domain.cn",["match"]="\\/v\\d+\\/[\\/a-zA-Z_-]+",["switch"]=true,["limit"]=0}
    }
    -- 设置白名单
    _M.whitelist_ips = {
          "127.0.0.1",
          "10.0.0.0/8",
          "172.16.0.0/12",
          "192.168.0.0/16",
    }
    
### 数据获取
    
    开启集群 获取数据方式 GET http://knight.domian.cn/admin/stats/get
    未开启stats_redis_dump_switch GET http://knight.domian.cn/admin/stats/loadGet
    
### 数据格式
    
    [{"success_time_avg":"3.52","flow_all":"219311.76","fail":45542,"flow_avg":"0.41","success_upstream_time":1314682.3707269,"fail_upstream_time_avg":"3.52","fail_time_avg":"5.46","success_ratio":"99.992","fail_time":248548.99999993,"success_time":1917575642.5463,"total":544744593,"success_upstream_time_avg":"2.41","api":"knightapi-\/v1\/answer\/"}]

### 数据收集生成图形报表
![](https://raw.githubusercontent.com/songweihang/ngx-lua-knight/master/doc/img/%E6%9F%A5%E8%AF%A2%E5%BD%93%E6%97%A5api%E6%8E%A5%E5%8F%A3%E6%89%A7%E8%A1%8C%E6%83%85%E5%86%B5.png)

![](https://github.com/songweihang/ngx-lua-knight/blob/master/doc/img/%E7%BD%91%E5%85%B3%E6%9C%8D%E5%8A%A1%E6%B5%81%E9%87%8F%E8%B5%B0%E5%8A%BF%E5%9B%BE.png?raw=true)    