local config = require("lapis.config")


local themes = {
  kittygram_light = {
    name = "kittygram_light",
    display_name = "Kittygram Light",
    url = "/static/style.css",
  },
  kittygram_dark = {
    name = "kittygram_dark",
    display_name = "Kittygram Dark",
    url = "/static/themes/kittygram-dark.css",
  }
}


config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",
  allow_json = true,
  themes = themes,
  default_theme = "kittygram_light"
})

config("production", {
  port = "80",
  code_cache = "on",
  num_workers = "4",
  allow_json = false,
  themes = themes,
  default_theme = "kittygram_light"
})
