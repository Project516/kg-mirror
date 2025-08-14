local http = require("socket.http")

local headers_table = {
    ["x-ig-app-id"] = "936619743392459",
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}

local user_info = {}
local response, code, headers = http.request{
    method = "GET",
    url = "https://google.com",
    headers = headers_table
}


print("Response Code: " .. tostring(code))
print("Response Body: " .. tostring(response))
print("Headers: " .. tostring(headers))


