local json = require("cjson")
local get_redis = require("lapis.redis").get_redis
local errors = require("lib.structures").errors
local queries = require("lib.structures").queries
local format_post = require("lib.structures").format_post
local graphql_request = require("lib.send_instagram_graphql_request")
local config = require("lapis.config").get()

local POSITIVE_EXPIRE_TIME = config.cache.expire_times.posts.positive
local NEGATIVE_EXPIRE_TIME = config.cache.expire_times.posts.negative


local function get_post_graphql(shortcode)
    local redis = get_redis()
    local post_query
    if not redis then
        ngx.log(ngx.ERR, "Redis connection failed: ", err)
    else
        post_query = redis:get("ig:shortcode:" .. shortcode)
    end

    -- check if redis returned anything.
    if redis and post_query ~= ngx.null then
        local post = json.decode(post_query)
        -- shortcodes that return no posts are cached.
        if post.has_errors and post.error_type == "not_found" then
            return errors.not_found{
                message = "Post not found. (note: result was cached.)",
                blob = json.decode(post.error_info.blob)
            }
        end

        return post
    else
        local payload, doc_id = queries.shortcode(shortcode)
        local post = graphql_request(payload, doc_id, "posts")

        if post.data and post.data.xdt_shortcode_media == json.null then
            -- cache a post if its not found
            local post_error = errors.not_found{
                message = "Post not found. (Note: this result was cached.)",
                blob = post
            }
            if redis then
                redis:set("ig:shortcode:" .. shortcode, json.encode(post_error), "EX", NEGATIVE_EXPIRE_TIME)
            end
            return post_error
        elseif post.status == "fail" and post.require_login == true then
            return errors.ratelimited{
                blob = post
            }
        end

        local formatted_post = format_post.from_shortcode(post.data.xdt_shortcode_media)
        if redis then
            redis:set("ig:shortcode:" .. shortcode, json.encode(formatted_post), "EX", POSITIVE_EXPIRE_TIME)
        end
        return formatted_post
    end
end


return get_post_graphql
