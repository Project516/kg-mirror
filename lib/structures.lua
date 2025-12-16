local json = require("cjson")
local doc_ids = {
    shortcode = "8845758582119845",
    user_info = "33257018913889225",
    comments = "25060748103519434",
    search = "24146980661639222",
    user_posts = "23893796620241262",
}

local queries = {
    shortcode = function(shortcode)
        return {
            shortcode = shortcode,
            fetch_tagged_user_count = json.null,
            hoisted_comment_id = json.null,
            hoisted_reply_id = json.null
        }, doc_ids.shortcode
    end,
    comments = function(post_id, sort_order)
        return {
            after = json.null, -- while an after_cursor _is_ exposed while logged out, this endpoint will only ever return the same page of comments when logged out.
            before = json.null,
            first = 30, -- I'm pretty sure this is the amount of comments to fetch at a time.
            last = json.null,
            media_id = post_id,
            sort_order = sort_order, -- leaving this at the default. would be cool to make this controllable.
            __relay_internal__pv__PolarisIsLoggedInrelayprovider = true
        }, doc_ids.comments
    end,
    user_info = function(user_id)
        return {
            enable_integrity_filters = true,
            id = user_id,
            render_surface = "PROFILE",
            __relay_internal__pv__PolarisProjectCannesLoggedInEnabledrelayprovider = true,
            __relay_internal__pv__PolarisCannesGuardianExperienceEnabledrelayprovider = true,
            __relay_internal__pv__PolarisCASB976ProfileEnabledrelayprovider = false,
            __relay_internal__pv__PolarisRepostsConsumptionEnabledrelayprovider = false
        }, doc_ids.user_info
    end,
    user_posts = function(username, count, after_cursor)
        if not after_cursor then
            after_cursor = json.null
        end
        return {
            after = after_cursor,
            before = json.null,
            data = {
                count = count,
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
        }, doc_ids.user_posts
    end,
    search = function(query)
        return {
            hasQuery = true,
            data = {
                query = query
            }
        }, doc_ids.search
    end,
}

return { queries = queries, doc_ids = doc_ids }
