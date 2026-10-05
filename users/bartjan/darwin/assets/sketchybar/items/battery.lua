local colors   = require("colors")
local icons    = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "battery", {
  position    = "right",
  update_freq = 120,
  icon = {
    font = {
      family = settings.font.icons,
      style  = settings.font.style_map["Regular"],
      size   = 20.0,
    },
  },
  label = {
    font = { family = settings.font.numbers, size = 16.0 },
  },
})

battery:subscribe({ "routine", "forced", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(out)
    local _, _, charge_str = string.find(out, "(%d+)%%")
    if not charge_str then return end
    local charge   = tonumber(charge_str)
    local charging = string.find(out, "AC Power") ~= nil

    local icon, color
    if charging then
      icon, color = icons.battery.charging, colors.green
    elseif charge > 80 then icon, color = icons.battery._100, colors.green
    elseif charge > 60 then icon, color = icons.battery._75,  colors.green
    elseif charge > 40 then icon, color = icons.battery._50,  colors.white
    elseif charge > 20 then icon, color = icons.battery._25,  colors.orange
    else                    icon, color = icons.battery._0,   colors.red
    end

    battery:set({
      icon  = { string = icon, color = color },
      label = { string = charge .. "%" },
    })
  end)
end)
