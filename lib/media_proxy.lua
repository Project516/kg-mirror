local lapis = require("lapis")
local app = lapis.Application()

local http = require("resty.http")
local util = require("lapis.util")

app:get("/mediaproxy", function(self)
    local httpc = http.new()
    local image_uri = util.unescape(self.params.url)

    local res, err = httpc:request_uri(image_uri, { method = "GET" })

    if not res then
        ngx.log(ngx.ERR, "[mediaproxy] Request Failed: ", err)
        return "Request Failed"
    end

    return {
        res.body,
        layout = false,
        headers = { ["Content-Type"] = res.headers["Content-Type"] }
    }

end)

return app
