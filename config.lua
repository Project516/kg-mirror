local config = require("lapis.config")


config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  allow_json = true,
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
})
