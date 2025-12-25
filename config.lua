local config = require("lapis.config")

local themes = require("conf.themes")
local proxies = require("conf.proxies")
local cache = require("conf.cache")


-- more configurations in the /conf directory.

config({"development", "production", "docker"}, {
  server = "nginx",
  default_theme = "auto",
  ipv6 = "off", -- change this to "on" to allow requests over ipv6. Will default to ipv4 otherwise.
  resolver = "8.8.8.8", -- DNS resolver, currently set to google's DNS server.
  trusted_certificate = "/etc/ssl/certs/ca-certificates.crt", -- a path to a file containing trusted CA certs. See: https://github.com/openresty/lua-nginx-module#lua_ssl_trusted_certificate
  themes = themes, -- see: conf/themes.lua
  proxies = proxies, -- see: conf/proxies.lua
  cache = cache, -- see: conf/cache.lua
  sqlite = {
    database = "kittygram.sqlite"
  },
  redis = {
    host = "127.0.0.1",
    port = 6379
  }
})

config("development", {
  port = "8081",
  code_cache = "off",
  num_workers = "1",
  allow_json = true, -- allows json responses if the `json` get param is set to true. Useful for debugging.
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
})

-- configurations specific to docker.
config("docker", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
  resolver = "127.0.0.11",
  redis = {
    host = "redis",
    port = 6379,
  }
})
