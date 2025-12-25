
local cache = {
    -- the time it takes for a cached item to expire, in seconds.
    -- Positive is for when an item is found, negative for if an item doesn't exist.
    expire_times = {
        posts = {
            negative = 1800,
            positive = 3600
        },
        user_info = {
            positive = 86400,
            negative = 0, -- this value isn't used currently. May be used in future.
        }
    }
}

return cache
