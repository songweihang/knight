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

_M.statsPrefixConf = {
    ["http_total"]                     = "T_",
    ["http_fail"]                      = "F_",
    ["http_success_time"]              = "S_T_",
    ["http_fail_time"]                 = "F_T_",
    ["http_success_upstream_time"]     = "S_UT_",
    ["http_fail_upstream_time"]        = "F_UT_",
}

_M.statsAllSwitchConf    = true

_M.statsMatchSwitchConf  = true

_M.statsMatchConf = {
    {["match"]="[a-z A-Z]{1,10}\\.[a-z A-Z]{1,10}\\.[a-z A-Z]{1,10}",["switch"]=true,["limit"]=false}
}

return _M