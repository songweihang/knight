local modulename = "configInit"
local _M = {}

_M._VERSION = '0.1'

_M.knightJsonPath =  '/Users/apple/Jakin/knight/config/knight.json'

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

_M.stats_main_conf = {
    ["total"]                     = "T",
    ["fail"]                      = "F",
    ["success_time"]              = "S_T",
    ["fail_time"]                 = "F_T",
    ["success_upstream_time"]     = "S_UT",
    ["fail_upstream_time"]        = "F_UT",
}

_M.stats_main_switch   = true

_M.stats_all_switch    = true

_M.stats_match_switch  = true

_M.stats_match_conf = {
    {["match"]="[a-z A-Z]{1,10}\\.[a-z A-Z]{1,10}\\.[a-z A-Z]{1,10}",["switch"]=true,["limit"]=false,["host"]="127.0.0.1"}
}

return _M