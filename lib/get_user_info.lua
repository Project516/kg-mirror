local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local http = require("resty.http")
local json = require("cjson")
local util = require("lapis.util")
local helpers = require("lib.helpers")


local doc_id = "24644030398570558"

local instagram_headers = {
    ["X-IG-App-ID"] = "936619743392459", -- TODO: let this be configurable
    ["X-CSRFToken"] = "exampletexthere", -- this can be anything.  TODO: probably should make it configurable as well
    ["Content-Type"] =  "application/x-www-form-urlencoded",
    ["Accept"] =  "*/*"
}


-- This method gets ratelimited too fast to be useful. Still documented here.

local function get_user_info_api(username)
    local start_uri = "https://www.instagram.com/api/v1/users/web_profile_info/?username="
    local httpc = http.new()

    local user_request = httpc:request_uri(start_uri .. username, {
        headers = instagram_headers
    })

    if helpers.check_nested_field(json.decode(user_request.body), "data", "user") then
        return json.decode(user_request.body).data.user  
    else
        return json.decode(user_request.body)
    end
end

local function get_user_info_graphql(userid)
    local payload = {
        enable_integrity_filters = true,
        id = userid,
        render_surface = "PROFILE",
        __relay_internal__pv__PolarisProjectCannesEnabledrelayprovider = false,
        __relay_internal__pv__PolarisProjectCannesLoggedInEnabledrelayprovider = false,
        __relay_internal__pv__PolarisProjectCannesLoggedOutEnabledrelayprovider = false,
        __relay_internal__pv__PolarisCannesGuardianExperienceEnabledrelayprovider =  false,
        __relay_internal__pv__PolarisCASB976ProfileEnabledrelayprovider = false
    }

    local user_info = instagram_graphql_request(payload, doc_id, "user_info")

    return user_info
end


return get_user_info_graphql
