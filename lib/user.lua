local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local helpers = require("lib.helpers")
local queries = require("lib.structures").queries
local json = require("cjson")
local get_user_id = require("lib.get_user_id_web")
local user_id_db = require("models.user_ids")


local function get_user_posts(username, cursor)

    local payload, doc_id = queries.user_posts(username, 20, cursor)
    local posts_request = instagram_graphql_request(payload, doc_id, "user_posts")

    -- Check if there is posts in the response.
    if not posts_request.errors and helpers.check_nested_field(posts_request, "data", "xdt_api__v1__feed__user_timeline_graphql_connection", "edges") then
        local posts = posts_request.data.xdt_api__v1__feed__user_timeline_graphql_connection.edges
        local end_cursor = posts_request.data.xdt_api__v1__feed__user_timeline_graphql_connection.page_info.end_cursor

        return { posts = posts, end_cursor = end_cursor }

    elseif posts_request.errors and posts_request.errors[1].code == 4630001 then
        return {
            has_errors = true,
            error_type = "not_found",
            error_info = {
                message = "User not found.",
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

-- this could probably do with more error handling.
local function get_user_info(user_id)
    local payload, doc_id = queries.user_info(user_id)
    local user_info = instagram_graphql_request(payload, doc_id, "user_info")
    return user_info.data.user
end



-- Instagram fetches user info based on ids,
-- fetching posts also returns the user's id. I can then fetch the user info based on that.
-- this method is pretty naive. Like the rest of this project :P
-- If a user has no posts (or is private), then their userid is retrieved from their user page.
-- All user ids are stored for later use, as profile pages are ratelimited heavily.

local function arrange_user_data(username, after_cursor)
    local user_posts = {}
    local user_id = false

    -- check if a cursor is present (for pagination)
    if after_cursor then
        user_posts = get_user_posts(username, after_cursor)
    else
        user_posts = get_user_posts(username)
    end

    if user_posts.has_errors then
        return user_posts
    end

    if #user_posts < 1 then
        if user_id_db.get_user_id(username) then
            user_id = user_id_db.get_user_id(username)
        else
            user_id = get_user_id(username)
            if user_id.has_errors then
                return user_id
            else
                -- save id for later.
                user_id_db.save_user_id(username, user_id)
            end
        end
    else
        if not helpers.check_nested_field(user_posts.posts[1], "node", "coauthor_producers", 1) then
            user_id = user_posts.posts[1].node.owner.id
            user_id_db.save_user_id(user_posts.posts[1].node.owner.username, user_id)
        elseif helpers.check_nested_field(user_posts[1], "node", "coauthor_producers", 1) then
            -- I'm not entirely sure if this is always accurate, so user ids found here aren't saved.
            user_id = post.node.coauthor_producers[1]
        end
    end


    local user_info = get_user_info(user_id)
    return {
        posts = user_posts.posts,
        user_info = user_info,
        end_cursor = user_posts.end_cursor
    }
end

return arrange_user_data
