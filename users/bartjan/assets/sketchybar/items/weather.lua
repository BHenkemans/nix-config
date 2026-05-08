local colors   = require("colors")
local settings = require("settings")

local DEFAULT_GLYPH = "󰖕"

-- Map wttr.in (WMO-based) weather codes to NerdFont MD weather glyphs.
-- Categories collapsed to keep the table small and easy to tweak.
local function code_to_glyph(code)
  code = tonumber(code)
  if not code then return DEFAULT_GLYPH end

  if code == 113 then return "󰖙" end                       -- clear / sunny
  if code == 116 then return "󰖕" end                       -- partly cloudy
  if code == 119 or code == 122 then return "󰖐" end       -- cloudy / overcast
  if code == 143 or code == 248 or code == 260 then return "󰖑" end -- fog / mist

  -- thunder
  if code == 200 or code == 386 or code == 389
     or code == 392 or code == 395 then return "󰖓" end

  -- snow (incl. ice pellets, blizzard)
  if code == 179 or code == 227 or code == 230
     or (code >= 323 and code <= 338)
     or code == 350 or code == 368 or code == 371
     or code == 374 or code == 377 then return "󰖘" end

  -- sleet (rain+snow mix)
  if code == 182 or code == 185
     or code == 317 or code == 320
     or code == 362 or code == 365 then return "󰙿" end

  -- everything else wet → rain
  return "󰖗"
end

local location = os.getenv("WEATHER_LOCATION") or ""
local fetch_cmd = string.format(
  [[curl -s --max-time 10 'wttr.in/%s?format=j1' 2>/dev/null | ]] ..
  [[jq -r '.current_condition[0] | "\(.weatherCode) \(.temp_C)"']],
  location
)

local weather = sbar.add("item", "weather", {
  position    = "right",
  update_freq = 900, -- 15 min; wttr.in doesn't change much faster than that
  icon = {
    string = DEFAULT_GLYPH,
    color  = colors.white,
    font = {
      family = settings.font.icons,
      style  = settings.font.style_map["Regular"],
      size   = 18.0,
    },
  },
  label = {
    string = "—",
    color  = colors.white,
    font   = { family = settings.font.numbers, size = 16.0 },
  },
  click_script = "osascript -e 'open location \"https://wttr.in/" .. location .. "\"'",
})

weather:subscribe({ "routine", "forced" }, function()
  sbar.exec(fetch_cmd, function(out)
    local code, temp = out:match("(%S+)%s+(%-?%d+)")
    if not code or not temp then return end
    weather:set({
      icon  = { string = code_to_glyph(code) },
      label = { string = temp .. "°" },
    })
  end)
end)
