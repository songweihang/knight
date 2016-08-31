local modulename = "configInit"
local _M = {}

_M._VERSION = '0.1'

_M.knightJsonPath =  '../config/knight.json'

_M.lockConf = {
    ["exptime"] = 0.001
}

_M.redisConf = {
    ["uds"]      = '/tmp/redis.sock',
    ["host"]     = '127.0.0.1',
    ["port"]     = '6379',
    ["poolsize"] = 1000,
    ["idletime"] = 90000, 
    ["timeout"]  = 10000,
    ["dbid"]     = 0,
}

_M.stats_all_switch    = false

_M.stats_all_conf = {
    {["switch"]=true,["limit"]=false,["host"]="127.0.0.1"}
}

_M.stats_match_switch  = true

_M.stats_match_conf = {
    {["host"]="127.0.0.1",["match"]="\\/api\\/v\\d+\\/[\\/ a-z A-Z]+",["switch"]=true,["limit"]=0}
}

--访问白名单
_M.whitelist_ips = {
    "127.0.0.1"
}

--限流
_M.limit = {
    ['dict_name'] = 'imit_conf',
    ['req'] = {["dict_name"]='my_limit_req_store',["switch"]=true,["rate"]=100,["burst"]=50},
    ['conn'] = {["dict_name"]='my_limit_conn_store',["switch"]=true,["rate"]=10000,["burst"]=5000}
}

return _M