local colors   = require("colors")
local settings = require("settings")

local DEFAULT_GLYPH = "󰖕"
local SUNRISE_GLYPH = "󰖜" -- mdi weather-sunset-up
local SUNSET_GLYPH  = "󰖛" -- mdi weather-sunset-down

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

-- Parse an ISO 8601 datetime ("2026-06-21T05:31") into minutes since midnight.
local function parse_iso_minutes(s)
  local h, m = (s or ""):match("T(%d+):(%d+)")
  if not h then return nil end
  return tonumber(h) * 60 + tonumber(m)
end

local function fmt(minutes)
  return string.format("%02d:%02d", math.floor(minutes / 60), minutes % 60)
end

local function format_delta(seconds)
  if not seconds then return nil end
  local total = math.floor(math.abs(seconds) + 0.5)
  local sign  = seconds >= 0 and "+" or "-"
  local h, m, s = math.floor(total / 3600), math.floor((total % 3600) / 60), total % 60
  if h > 0 then return string.format("%s%dh%02dm%02ds", sign, h, m, s) end
  if m > 0 then return string.format("%s%dm%02ds", sign, m, s) end
  return string.format("%s%ds", sign, s)
end

local location = os.getenv("WEATHER_LOCATION") or ""
-- wttr.in: weather code, temp, and lat/lon (resolved from WEATHER_LOCATION).
-- open-meteo: sunrise/sunset (today + tomorrow) and daylight_duration
--   for today vs yesterday, in seconds, so the delta has sub-minute resolution.
local fetch_cmd = string.format([[
WX=$(curl -s --max-time 10 'wttr.in/%s?format=j1' 2>/dev/null \
  | jq -r '[.current_condition[0].weatherCode, .current_condition[0].temp_C, .nearest_area[0].latitude, .nearest_area[0].longitude] | @tsv' 2>/dev/null)
[ -z "$WX" ] && exit 0
LAT=$(printf '%%s' "$WX" | cut -f3)
LON=$(printf '%%s' "$WX" | cut -f4)
ASTRO=$(curl -s --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&daily=sunrise,sunset,daylight_duration&past_days=1&forecast_days=2&timezone=auto" 2>/dev/null \
  | jq -r '[.daily.sunrise[1], .daily.sunset[1], .daily.sunrise[2], (.daily.daylight_duration[1] - .daily.daylight_duration[0])] | @tsv' 2>/dev/null)
[ -z "$ASTRO" ] && exit 0
printf '%%s\t%%s\n' "$(printf '%%s' "$WX" | cut -f1,2)" "$ASTRO"
]], location)

-- "sun" shows the next sunrise/sunset, "weather" shows code + temperature.
local mode  = "sun"
local state = {}

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
})

-- The next sun event relative to now: today's sunrise, today's sunset,
-- or (once the sun has set) tomorrow's sunrise.
local function next_sun_event()
  if not (state.sunrise0 and state.sunset0 and state.sunrise1) then
    return nil
  end
  local now = os.date("*t")
  local minutes = now.hour * 60 + now.min
  if minutes < state.sunrise0 then
    return SUNRISE_GLYPH, fmt(state.sunrise0)
  elseif minutes < state.sunset0 then
    return SUNSET_GLYPH, fmt(state.sunset0)
  else
    return SUNRISE_GLYPH, fmt(state.sunrise1)
  end
end

local function render()
  if mode == "sun" then
    local glyph, time = next_sun_event()
    if glyph then
      local label    = time
      local delta_str = format_delta(state.daylight_delta)
      if delta_str then label = label .. " " .. delta_str end
      weather:set({ icon = { string = glyph }, label = { string = label } })
      return
    end
  end
  weather:set({
    icon  = { string = code_to_glyph(state.code) },
    label = { string = state.temp and (state.temp .. "°") or "—" },
  })
end

weather:subscribe({ "routine", "forced" }, function()
  sbar.exec(fetch_cmd, function(out)
    local code, temp, sr0, ss0, sr1, delta =
      out:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t\n]*)")
    if not code then return end
    state.code           = code
    state.temp           = temp
    state.sunrise0       = parse_iso_minutes(sr0)
    state.sunset0        = parse_iso_minutes(ss0)
    state.sunrise1       = parse_iso_minutes(sr1)
    state.daylight_delta = tonumber(delta)
    render()
  end)
end)

weather:subscribe("mouse.clicked", function()
  mode = (mode == "weather") and "sun" or "weather"
  render()
end)
