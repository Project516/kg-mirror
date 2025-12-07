-- to configure proxies, replace "false" with the proxies url.
-- note: use 127.0.0.1 instead of localhost.
-- This only supports http proxies, not SOCKS.

local alse = "http://127.0.0.1:9500"
local proxies = {
    posts = alse, -- Posts/reels, anything with a shortcode.
    user_info = alse,
    search = alse,
    user_posts = alse,
    comments = alse,
}

return proxies
