local config = require("lapis.config")

local themes = require("conf.themes")
local proxies = require("conf.proxies")



-- more configurations in the /conf directory.

config({"development", "production"}, {
  server = "nginx",
  default_theme = "auto",
  ipv6 = "off", -- change this to "on" to allow requests over ipv6. Will default to ipv4 otherwise.
  resolver = "8.8.8.8", -- DNS resolver, currently set to google's DNS server.
  trusted_certificate = "/etc/ssl/certs/ca-certificates.crt", -- a path to a file containing trusted CA certs. See: https://github.com/openresty/lua-nginx-module#lua_ssl_trusted_certificate
  themes = themes, -- see: conf/themes.lua
  proxies = proxies, -- see: conf/proxies.lua
  sqlite = {
    database = "kittygram.sqlite"
  }
})

config("development", {
  port = "8080",
  code_cache = "off",
  num_workers = "1",
  allow_json = true, -- allows json responses (i.e, returns instagram's json response if the json GET param is set to true). Useful for debugging.
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
})
