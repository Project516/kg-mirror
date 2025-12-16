-- to configure proxies, replace "false" with the proxies url.
-- note: use 127.0.0.1 instead of localhost.
-- This only supports http proxies, not SOCKS.


local proxies = {
    posts = false, -- Posts/reels, anything with a shortcode.
    user_info = false,
    search = false,
    user_posts = false,
    comments = false,
}

return proxies
