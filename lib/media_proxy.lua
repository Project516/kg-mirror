local lapis = require("lapis")
local app = lapis.Application()

local http = require("resty.http")
local util = require("lapis.util")

local WHITELIST = {
    "cdninstagram.com",
    "fbcdn.net"
}

app:get("/mediaproxy", function(self)
    local image_uri = util.unescape(self.params.url)

    local match = ngx.re.match(image_uri, [[^(https?)://([^/]+)]], "jo")
    if not match then
        return { status = 400, "Invalid URL" }
    end

    local host = match[2]

    local allowed = false
    for _, domain in ipairs(WHITELIST) do
        if host == domain or ngx.re.find(host, [[\.]] .. domain .. "$", "jo") then
            allowed = true
            break
        end
    end

    if not allowed then
        return { status = 403, "Domain Not Allowed" }
    end

    local httpc = http.new()
    local res, err = httpc:request_uri(image_uri, { method = "GET" })

    if not res then
        ngx.log(ngx.ERR, "[mediaproxy] Request Failed: ", err)
        return { status = 502, "Request Failed" }
    end

    return {
        res.body,
        layout = false,
        headers = { ["Content-Type"] = res.headers["Content-Type"] }
    }
end)

return app
