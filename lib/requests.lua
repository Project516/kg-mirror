local http = require("resty.http")
local ltn12 = require("ltn12")

local json = require("cjson")


local requests = {
    get = function(url, options)
        local httpc = http.new()

        local response = {}

         local req = {
            method = "GET",
        }

        if type(options) == "table" and type(options.headers) == "table" then
            req.headers = options.headers
        end

        local result, err = httpc:request_uri(url, req)
        
        return { 
            body = table.concat(response),
            code = code,
            headers = headers,
            status = status
        }
    end,
    post = function(url, body, options) 
        local response = {}
        local req = {
            method = "POST",
            url = url,
            sink = ltn12.sink.table(response),
            source = ltn12.source.string(body)
        }
        if type(options) == "table" and type(options.headers) == "table" then
            req.headers = options.headers
        end
        local result, code, headers, status = http.request(req)
        
        return { 
            body = table.concat(response),
            code = code,
            headers = headers,
            status = status
        }
    end

}


return { get = requests.get, post = requests.post }