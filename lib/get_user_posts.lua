local http = require("resty.http")
local util = require("lapis.util")
local json = require("cjson")


local instagram_headers = {
    ["X-IG-App-ID"] = "936619743392459", -- TODO: let this be configurable
    ["X-CSRFToken"] = "exampletexthere", -- this can be anything.  TODO: probably should make it configurable as well
    ["Content-Type"] =  "application/x-www-form-urlencoded",
    ["Accept"] =  "*/*"
}

local doc_id = "23893796620241262"

local function get_user_posts(username, cursor)
    local httpc = http.new()
    -- setup the request body

    local after_cursor = false
    if cursor then
        after_cursor = cursor
    else
        after_cursor = json.null
    end


    local request_body = "variables=" .. util.escape(json.encode({
        after = after_cursor, 
        before = json.null, -- nil is so counter-inituative.
        data = {
            count = 20,
            include_reel_media_seen_timestamp = true, -- no idea what this stuff does, but the requests fail without them ¯\_(ツ)_/¯
            include_relationship_info = true,
            latest_besties_reel_media = true,
            latest_reel_media = true
        },
        first = 12,
        last = json.null,
        username = username,
        __relay_internal__pv__PolarisIsLoggedInrelayprovider = true, -- no idea what this does either
        __relay_internal__pv__PolarisShareSheetV3relayprovider = true
    })) .. "&doc_id=" .. doc_id

    
    local posts_request = httpc:request_uri("https://www.instagram.com/graphql/query", {
        method = "POST",
        headers = instagram_headers,
        body = request_body,
    })

    local posts = json.decode(posts_request.body).data.xdt_api__v1__feed__user_timeline_graphql_connection.edges
    local end_cursor = json.decode(posts_request.body).data.xdt_api__v1__feed__user_timeline_graphql_connection.page_info.end_cursor

    return { posts = posts, end_cursor = end_cursor }
end

return get_user_posts