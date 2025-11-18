local lapis = require("lapis")
local http = require("resty.http")
local util = require("lapis.util")
local app = lapis.Application()
local json = require("cjson")
local helpers = require("lib.helpers")

app:enable("etlua")
app.layout = require("views.layout")

local get_post = require("lib.get_post")
local get_user_info = require("lib.get_user_info")
local get_user_posts = require("lib.get_user_posts")
local search = require("lib.search")


-- welcome to the soup


app:before_filter(function(self)
    self.view_on_instagram_link = "https://www.instagram.com" .. self.req.parsed_url.path
end)
--todo: replace this with a proper page
app:get("/", function(self)
    
    return { [[
 _    _ _   _
| | _(_| |_| |_ _   _  __ _ _ __ __ _ _ __ ___
| |/ | | __| __| | | |/ _` | '__/ _` | '_ ` _ \
|   <| | |_| |_| |_| | (_| | | | (_| | | | | | |
|_|\_|_|\__|\__|\__, |\__, |_|  \__,_|_| |_| |_|
                |___/ |___/
This is an instance of kittygram, an instagram frontend.  
Try replacing the "www.instagram.com" part of a post's url with this instances address to try it!  

  
    ]] , content_type = "text/plain", layout = false}
end)


local function show_post(self)
  local post = get_post(self.params.shortcode)

  if post.post.has_error == true then
    self.error = post.post
    self.page_title = "Not Found | Kittygram"
    return { status = 404, render = "404" }
  else
    self.post = post.post -- heh
    self.comments = post.comments
    self.page_title = "A post by " ..  post.post.user.username

    if self.params.json == "true" then
      return { json = post }
    end
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
  

  local res, err = httpc:request_uri(image_uri, {
    method = "GET"
  })

  if not res then
    ngx.log(ngx.ERR, "[mediaproxy] Request Failed: ", err)
    return "Request Failed"
  end
  
  return { res.body, layout = false,  headers = {
    ["Content-Type"] = res.headers["Content-Type"]
  } }

end)

app:get("/:username", function(self)
  

  self.page_title = "@" .. self.params.username .. " - kittygram"
  local user_posts = {}
  if self.params.after then
    user_posts = get_user_posts(self.params.username, self.params.after)
  else
    user_posts = get_user_posts(self.params.username)
  end

  self.posts = user_posts.posts

  self.end_cursor = user_posts.end_cursor
  -- ok, so. Instagram fetches users based on ids, I _could_ scrape the user page, but this way works better.
  -- bascially, fetching posts returns the user's id. I can then fetch the user info based on that.
  -- this method is pretty naive. Like the rest of this project :P 

  local user_id = false
  -- todo: fix this atrocity
  for _, post in ipairs(user_posts.posts) do
    if not helpers.check_nested_field(post, "node", "coauthor_producers", 1) then
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
    return { json = {
      user_posts,
      user_info
    } }
  end
  --return { json = user_posts }
  return { render =  "user" }
end)

app:get("/search", function(self)
  if self.params.q then

    local search_results = search(self.params.q)
    self.page_title = "Search for \"" .. self.params.q .. "\" | kittygram"
    self.search_query = self.params.q
    self.search_results = search_results

    --return { json = search_results }
    return { render = "search_results" }
  else
    self.page_title = "Search | kittygram"
    return { render = "search"}
  end

end)

return app
