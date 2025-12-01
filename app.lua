local lapis = require("lapis")
local http = require("resty.http")
local util = require("lapis.util")
local config = require("lapis.config").get()
local app = lapis.Application()


local json = require("cjson")
local helpers = require("lib.helpers")

app:enable("etlua")
app.layout = require("views.layout")

local get_post = require("lib.get_post")
local get_user_info = require("lib.get_user_info")
local get_user_posts = require("lib.get_user_posts")
local search = require("lib.search")
local get_comments = require("lib.get_comments")
-- welcome to the soup


-- generate the "view on instagram" link.
app:before_filter(function(self)
    self.view_on_instagram_link = "https://www.instagram.com" ..
                                      self.req.parsed_url.path
end)



app:get("/", function(self)
    self.page_title = "kittygram"
    self.instance_about_message = config.instance_about

    return { render = "index" }
end)

local function show_post(self)
    local post = get_post(self.params.shortcode)

    if post.has_error == true then
        self.error = post

        if post.error_type == "not_found" then
            self.page_title = "Not Found | Kittygram"
            return { status = 404, render = "error" }
        else
            self.page_title = "Error | Kittygram"
            return { status = 500, render = error }
        end
    else
        self.post = post
        self.page_title = "A post by " .. post.owner.username
        local comments = get_comments(post.id)
        self.comments = comments
        if self.params.json == "true" then return { json = post } end
        return { render = "post" }
    end
end

app:get("/p/:shortcode", show_post)
app:get("/:username/p/:shortcode", show_post)
app:get("/reel/:shortcode", show_post)
app:get("/:username/reel/:shortcode", show_post)

-- instead of doing CORS fuckery, I just made a naive media proxy thing. 
app:get("/mediaproxy", function(self)
    local httpc = http.new()
    local image_uri = util.unescape(self.params.url)

    local res, err = httpc:request_uri(image_uri, { method = "GET" })

    if not res then
        ngx.log(ngx.ERR, "[mediaproxy] Request Failed: ", err)
        return "Request Failed"
    end

    return {
        res.body,
        layout = false,
        headers = { ["Content-Type"] = res.headers["Content-Type"] }
    }

end)

app:get("/:username", function(self)

    local user_posts = {}

    if self.params.after then
        user_posts = get_user_posts(self.params.username, self.params.after)
    else
        user_posts = get_user_posts(self.params.username)
    end
    -- check for errors.
    if user_posts.has_errors then
        self.error = user_posts
        if user_posts.error_type == "not_found" then
            self.page_title = "Not found | Kittygram"
            return { status = 404, render = "error" }
        else
            self.page_title = "Error | Kittygram"
            return { status = 500, render = "error" }
        end
    else
        self.page_title = "@" .. self.params.username .. " - kittygram"
        self.posts = user_posts.posts

        self.end_cursor = user_posts.end_cursor
        -- ok, so. Instagram fetches users based on ids, I _could_ scrape the user page, but this way works better.
        -- bascially, fetching posts returns the user's id. I can then fetch the user info based on that.
        -- this method is pretty naive. Like the rest of this project :P

        local user_id = false
        -- todo: fix this atrocity
        for _, post in ipairs(user_posts.posts) do
            if not helpers.check_nested_field(post, "node",
                                              "coauthor_producers", 1) then
                user_id = post.node.owner.id
                break
            end
        end
        if user_id == false then
            user_id = post.node.coauthor_producers[1].id
        end

        local user_info = get_user_info(user_id)
        self.user = user_info.data

        if self.params.json == "true" then
            return { json = { user_posts, user_info } }
        end
        -- return { json = user_posts }
        return { render = "user" }

    end
end)

app:get("/search", function(self)
    if self.params.q then

        local search_results = search(self.params.q)
        self.page_title = "Search for \"" .. self.params.q .. "\" | kittygram"
        self.search_query = self.params.q
        self.search_results = search_results

        -- return { json = search_results }
        return { render = "search_results" }
    else
        self.page_title = "Search | kittygram"
        return { render = "search" }
    end

end)

app:get("/*", function(self)
    self.error = {
        has_error = true,
        error_type = "route_not_defined",
        error_info = {
            error_message = "No route was defined for this request.",
            error_blob = nil,
        }
    }
    return { status = 404, render  = "error" }
end)


app:get("/test", function(self)
    local post = get_post("DQ6lrHzjEKJ")
    return {json = post}

end)
return app
