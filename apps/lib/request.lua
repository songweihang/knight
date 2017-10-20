
local _M = {
    _VERSION = '0.01'
}

_M.get = function()
    ngx.header["Content-Type"] = "application/json;charset=UTF-8"
    local args,method = nil,ngx.var.request_method
    ngx.req.read_body()
    if method == 'GET' or method == 'DELETE' then
        args = ngx.req.get_uri_args()
    else
        args = ngx.req.get_post_args()        
    end

    return args,method     
end


return _M