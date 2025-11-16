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
            errors = true,
            errors_info = json.encode(search_results)
        }
    elseif helpers.check_nested_field(search_results, "data", "xdt_api__v1__fbsearch__topsearch_connection") then
        return search_results.data.xdt_api__v1__fbsearch__topsearch_connection
    end

    return {
        errors = true,
        errors_info = "Something went wrong."
    }
end

return search
