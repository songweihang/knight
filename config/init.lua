local modulename = "configInit"
local _M = {}

local ngxshared   = ngx.shared
local denycc_conf = ngxshared.denycc_conf

_M._VERSION = '0.1'

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

_M.whitelist_ips = {
      "127.0.0.1",
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
}

_M.denycc_switch  = denycc_conf:get('denycc_switch') or 0

_M.denycc_rate_conf = {
    ["request"] =   denycc_conf:get('denycc_rate_request') or 500,
    ["ts"]      =   denycc_conf:get('denycc_rate_ts') or 60
}

return _M