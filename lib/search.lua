local instagram_graphql_request = require("lib.send_instagram_graphql_request")
local helpers = require("lib.helpers")

local doc_id = "24146980661639222"

local function search(query)

    local payload = {
        data = {
            query = query
        },
    hasQuery = true }

    local search_request = instagram_graphql_request(payload, doc_id)
    local search_results = search_request

    if search_results.errors then
        return {
            has_errors = true,
            error_type = "unknown",
            errors_info = {
                message = "An unknown error occurred.",
                blob = json.encode(search_results)
            }
        }
    elseif helpers.check_nested_field(search_results, "data", "xdt_api__v1__fbsearch__topsearch_connection") then
        return search_results.data.xdt_api__v1__fbsearch__topsearch_connection
    end

    return {
        has_errors = true,
        error_type = "unknown",
        error_info = {
            message = "Something went wrong.",
            blob = json.encode(search_results.data)
        }
    }
end

return search
