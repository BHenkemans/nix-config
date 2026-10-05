local colors   = require("colors")
local settings = require("settings")

local app_icons = {}
do
  local path = os.getenv("SKETCHYBAR_APP_FONT_LUA")
  if path then
    local ok, mod = pcall(dofile, path)
    if ok and type(mod) == "table" then app_icons = mod end
  end
end

local front = sbar.add("item", "front_app", {
  position = "left",
  display  = "active",
  updates  = true,
  icon = {
    string = ":default:",
    color  = colors.white,
    font = {
      family = settings.font.app_icons,
      style  = "Regular",
      size   = 20.0,
    },
    padding_left  = 10,
    padding_right = 6,
    y_offset      = -1,
  },
  label = { drawing = false },
})

front:subscribe("front_app_switched", function(env)
  local glyph = app_icons[env.INFO] or app_icons["Default"] or ":default:"
  front:set({ icon = { string = glyph } })
end)
