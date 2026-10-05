local colors   = require("colors")
local settings = require("settings")

local cal = sbar.add("item", "calendar", {
  position    = "right",
  update_freq = 30,
  icon = {
    color         = colors.white,
    padding_left  = 8,
    padding_right = 4,
    font = {
      family = settings.font.text,
      style  = settings.font.style_map["Semibold"],
      size   = 16.0,
    },
  },
  label = {
    color         = colors.white,
    padding_right = 10,
    font = {
      family = settings.font.numbers,
      style  = settings.font.style_map["Semibold"],
      size   = 16.0,
    },
  },
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
  cal:set({
    icon  = { string = os.date("%a %d %b") },
    label = { string = os.date("%H:%M") },
  })
end)
