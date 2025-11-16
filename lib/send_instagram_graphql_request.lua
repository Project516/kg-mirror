local http = require("resty.http")
local util = require("lapis.util")
local json = require("cjson")
local helpers = require("lib.helpers")

local instagram_headers = {
    ["X-IG-App-ID"] = "936619743392459", -- TODO: let this be configurable
    ["X-CSRFToken"] = "exampletexthere", -- this can be anything.  TODO: probably should make it configurable as well
    ["Content-Type"] =  "application/x-www-form-urlencoded",
    ["Accept"] =  "*/*"
}

local function graphql_request(request_payload, doc_id)
    local httpc = http.new()
    local request_body = "variables=" .. util.escape(json.encode(request_payload)) .. "&doc_id=" .. doc_id

    local request = httpc:request_uri("https://www.instagram.com/graphql/query", {
        method = "POST",
        headers = instagram_headers,
        body = request_body,
    })

    return json.decode(request.body)
end

return graphql_request
