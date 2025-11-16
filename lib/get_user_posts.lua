local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local json = require("cjson")

local doc_id = "23893796620241262"

local function get_user_posts(username, cursor)
    -- setup the request body

    local after_cursor = false
    if cursor then
        after_cursor = cursor
    else
        after_cursor = json.null
    end

    local payload = {
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
    }

    local posts_request = instagram_graphql_request(payload, doc_id)

    local posts = posts_request.data
                      .xdt_api__v1__feed__user_timeline_graphql_connection.edges
    local end_cursor = posts_request.data
                           .xdt_api__v1__feed__user_timeline_graphql_connection
                           .page_info.end_cursor

    return {posts = posts, end_cursor = end_cursor}
end

return get_user_posts
