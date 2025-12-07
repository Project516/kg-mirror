local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local helpers = require("lib.helpers")
local json = require("cjson")


local doc_id = "25060748103519434"


local function get_comments(post_id)

    local payload = {
            after = json.null, -- while an after_cursor _is_ exposed while logged out, this endpoint will only ever return the same page of comments when logged out.
            before = json.null,
            first = 30, -- I'm pretty sure this is the amount of comments to fetch at a time.
            last = json.null,
            media_id = post_id,
            sort_order = "popular", -- leaving this at the default. would be cool to make this controllable.
            __relay_internal__pv__PolarisIsLoggedInrelayprovider = true
        }


    local request = instagram_graphql_request(payload, doc_id, "comments")

    return request.data.xdt_api__v1__media__media_id__comments__connection.edges
end

return get_comments
