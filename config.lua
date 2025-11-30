local config = require("lapis.config")


local instance_about = [[
  The operator of this instance has not written an about message yet.
]]

config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  instance_about = instance_about
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  instance_about = instance_about
})
