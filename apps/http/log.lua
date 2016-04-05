local statusCache = ngx.shared.status
statusCache:set('status',ngx.var.status)
