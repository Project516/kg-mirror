local config = require("lapis.config")
local themes = require("themes")
local default_theme = "auto"




config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  allow_json = true,
  themes = themes,
  default_theme = default_theme,
  proxy = false
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
  themes = themes,
  default_theme = default_theme,
  proxy = false
})
