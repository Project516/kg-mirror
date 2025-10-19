local http = require("resty.http")
local json = require("cjson")
local util = require("lapis.util")


local doc_id = "24644030398570558"
local instagram_headers = {
    ["X-IG-App-ID"] = "936619743392459", -- TODO: let this be configurable
    ["X-CSRFToken"] = "exampletexthere", -- this can be anything.  TODO: probably should make it configurable as well
    ["Content-Type"] =  "application/x-www-form-urlencoded",
    ["Accept"] =  "*/*"
}

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

local function get_user_info_api(username)
    local start_uri = "https://www.instagram.com/api/v1/users/web_profile_info/?username="
    local httpc = http.new()

    local user_request = httpc:request_uri(start_uri .. username, {
        headers = instagram_headers
    })

    if check_nested_field(json.decode(user_request.body), "data", "user") then
        return json.decode(user_request.body).data.user  
    else
        return json.decode(user_request.body)
    end
end

local function get_user_info_graphql(userid)
    local graphql_uri = "https://instagram.com/graphql/query"
    local httpc = http.new()

    local request_body = "variables=" .. util.escape(json.encode({
        enable_integrity_filters = true,
        id = userid,
        render_surface = "PROFILE",
        __relay_internal__pv__PolarisProjectCannesEnabledrelayprovider = false,
        __relay_internal__pv__PolarisProjectCannesLoggedInEnabledrelayprovider = false,
        __relay_internal__pv__PolarisProjectCannesLoggedOutEnabledrelayprovider = false,
        __relay_internal__pv__PolarisCannesGuardianExperienceEnabledrelayprovider =  false,
        __relay_internal__pv__PolarisCASB976ProfileEnabledrelayprovider = false
    })) .. "&doc_id=" .. doc_id


    local user_info_request = httpc:request_uri(graphql_uri, {
        method = "POST",
        headers = instagram_headers,
        body = request_body
    })

    ngx.log(ngx.ERR, request_body .. "\n\n" .. user_info_request.body)

    return json.decode(user_info_request.body)
end


return get_user_info_graphql