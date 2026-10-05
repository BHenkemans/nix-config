local colors   = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style  = settings.font.style_map["Bold"],
      size   = 15.0,
    },
    color         = colors.white,
    padding_left  = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style  = settings.font.style_map["Semibold"],
      size   = 15.0,
    },
    color         = colors.white,
    padding_left  = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height        = 30,
    corner_radius = 6,
    border_width  = 0,
  },
  padding_left  = 4,
  padding_right = 4,
})
