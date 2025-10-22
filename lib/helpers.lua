local util = require("lapis.util") 

local function check_nested_field(tbl, ...)
    local current = tbl
    for _, key in ipairs({...}) do
        if type(current) ~= "table" then
            return nil 
        end
        current = current[key]
    end
    return current 
end


    
local proxy_url = function(url)
    return "/mediaproxy?url=" .. util.escape(url)
end 

return { check_nested_field = check_nested_field, proxy_url = proxy_url }