local http = require("resty.http")
local html = require("htmlparser")
local json = require("cjson")
local helpers = require("lib.helpers")


local totally_human_headers = {
    ["Accept"] =  "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    ["Sec-Fetch-Mode"] = "navigate"
}



local function get_post(shortcode)
    local httpc = http.new()
    
    local post_request, err = httpc:request_uri("https://www.instagram.com/p/" .. shortcode .. "/", {
        headers = totally_human_headers
    })

    
    if not post_request then
        ngx.log(ngx.ERR, "Request failed: " .. err)
    end
    local html_root = html.parse(post_request.body)
    local script_elements = html_root:select("[type='application/json']")

    local post_info = false
    local post_comments = false

    for _, element in pairs(script_elements) do
        local element_json = json.decode(element:getcontent())
        
        
        if helpers.check_nested_field(element_json, "require", 1, 4, 1, "__bbox", "require", 1, 4, 2, "__bbox", "result", "data", "xdt_api__v1__media__shortcode__web_info") then
            -- instagram's json structure is fucked.
            post_info = element_json.require[1][4][1].__bbox.require[1][4][2].__bbox.result.data.xdt_api__v1__media__shortcode__web_info.items[1]     
        end

        

        if helpers.check_nested_field(element_json, "require", 1, 4, 1, "__bbox", "require", 1, 4, 2, "__bbox", "result", "data", "xdt_api__v1__media__media_id__comments__connection", "edges") then
            post_comments = element_json.require[1][4][1].__bbox.require[1][4][2].__bbox.result.data.xdt_api__v1__media__media_id__comments__connection.edges
        end
        
    end
    if not post_info then  -- did you know I'm terrible at coding?
        post_info = { error = "Post info not found in page HTML.", req = post_request }
    end

    if not post_comments  then
        post_comments = { error = "Post comments not found in page HTML", req = post_request }
    end

    return { post = post_info, comments = post_comments }
end

return get_post