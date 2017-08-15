local modulename = "configInit"
local _M = {}

_M._VERSION = '0.1'

_M.redisConf = {
    ["uds"]      = '/tmp/redis.sock',
    ["host"]     = '127.0.0.1',
    ["port"]     = '6379',
    ["poolsize"] = 1000,
    ["idletime"] = 90000, 
    ["timeout"]  = 10000,
    ["dbid"]     = 1,
    ["auth"]     = ''
}

_M.stats_all_switch    = false

_M.stats_all_conf = {
    {["switch"]=false,["limit"]=false,["host"]="a.domain.cn"}
}

_M.stats_match_switch  = true

_M.stats_match_conf = {
    {["host"]="b.domain.cn",["match"]="\\/api\\/v\\d+\\/[\\/a-zA-Z]+",["switch"]=true,["limit"]=0},
    {["host"]="a.domain.cn",["match"]="\\/v\\d+\\/[\\/a-zA-Z_-]+",["switch"]=true,["limit"]=0},
    {["host"]="c.domain.cn",["match"]="\\/v\\d+\\/[\\/a-zA-Z_-]+",["switch"]=true,["limit"]=0}
}

return _M