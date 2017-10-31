### 如何使用CC防御模块
CC模块默认关闭 可以通过接口进行开启服务

    获取cc防御配置 GET http://knight.domian.cn/admin/denycc/get
    修改cc防御配置 GET http://knight.domian.cn/admin/denycc/store?denycc_switch=0&denycc_rate_request=501&denycc_rate_ts=60
    denycc_switch 0关闭 1开启
    denycc_rate_ts cc统计周期默认60秒不建议修改  
    denycc_rate_request denycc_rate_ts时间内单ip执行最大次数
    可以在knight/config/init.lua中whitelist_ips配置CC白名单，whitelist_ips会自动绕开CC限制，默认配置所有内网地址均加入白名单
    
如果遇到大量恶意请求系统也可以调用API封IP
    
    获取IP黑名单列表 GET  http://knight.domian.cn/admin/ip_blacklist/lists
    设置IP黑名单    GET  http://knight.domian.cn/admin/ip_blacklist/store?ip=127.0.0.2
    删除IP黑名单    GET  http://knight.domian.cn/admin/ip_blacklist/del?ip=127.0.0.2