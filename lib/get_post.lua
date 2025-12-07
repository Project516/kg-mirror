local json = require("cjson")
local graphql_request = require("lib.send_instagram_graphql_request")



local doc_id = "8845758582119845"



local function get_post_graphql(shortcode)
    local payload = {
        shortcode = shortcode,
        fetch_tagged_user_count = json.null,
        hoisted_comment_id = json.null,
        hoisted_reply_id = json.null
    }


    local post = graphql_request(payload, doc_id, "post")

    if post.data and post.data.xdt_shortcode_media == json.null then
        return {
            has_errors = true,
            error_type = "not_found",
            error_info = {
                message = "Post not found.",
                blob = json.encode(post)
            }
        }
    elseif post.status == "fail" and post.require_login == true then
        return {
            has_errors = true,
            error_type = "ratelimited",
            error_info = {
                message = "This instance may be rate-limited. Try again in a minute.",
                blob = json.encode(post)
            }
        }
    end


    return post.data.xdt_shortcode_media

end


return get_post_graphql
