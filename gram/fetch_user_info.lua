local requests = require("requests")
local json = require("cjson")

io.write("Enter the user's username: ")

local inputted_username = io.read()


local instagram_headers = {
    ["X-IG-App-ID"] = "936619743392459"
}



local user_info_request = requests.get("https://www.instagram.com/api/v1/users/web_profile_info/?username=" .. inputted_username, {
    headers = instagram_headers
})

local user_info = json.decode(user_info_request.body)



print("Username: " .. user_info.data.user.username)
print("Display Name: " .. user_info.data.user.full_name)
print("Biography: " .. user_info.data.user.biography)
print("Profile Picture URI: " .. user_info.data.user.profile_pic_url )
print("Id: " .. user_info.data.user.id)


