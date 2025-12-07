local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local helpers = require("lib.helpers")
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

    local posts_request = instagram_graphql_request(payload, doc_id, "user_posts")


    if not posts_request.errors and helpers.check_nested_field(posts_request, "data", "xdt_api__v1__feed__user_timeline_graphql_connection", "edges") then
        local posts = posts_request.data
                      .xdt_api__v1__feed__user_timeline_graphql_connection.edges
        local end_cursor = posts_request.data
                           .xdt_api__v1__feed__user_timeline_graphql_connection
                           .page_info.end_cursor
        return {posts = posts, end_cursor = end_cursor}
    elseif posts_request.errors and posts_request.errors[1].code == 4630001 then
        return {
            has_errors = true,
            error_type = "not_found",
            error_info = {
                message = "Post not found.",
                blob = json.encode(posts_request)
            }
        }
    elseif posts_request.status == "fail" and posts_request.require_login == true then
        return {
            has_errors = true,
            error_type = "ratelimited",
            error_info = {
                message = "This instance may be rate-limited. Try again in a minute.",
                blob = json.encode(posts_request)
            }
        }
    end

    return {
        has_errors = true,
        error_type = "unknown",
        error_info = {
            message = "Something went wrong.",
            blob = json.encode(posts_request)
        }
    }
end

return get_user_posts
