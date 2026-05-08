local colors   = require("colors")
local icons    = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = {
    font = {
      family = settings.font.icons,
      style  = settings.font.style_map["Regular"],
      size   = 18.0,
    },
  },
  label = {
    font = { family = settings.font.numbers, size = 16.0 },
  },
})

volume:subscribe("volume_change", function(env)
  local v = tonumber(env.INFO) or 0
  local icon
  if     v > 60 then icon = icons.volume._100
  elseif v > 30 then icon = icons.volume._66
  elseif v > 10 then icon = icons.volume._33
  elseif v > 0  then icon = icons.volume._10
  else               icon = icons.volume._0
  end
  volume:set({
    icon  = { string = icon },
    label = { string = v .. "%" },
  })
end)
