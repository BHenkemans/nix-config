local colors   = require("colors")
local icons    = require("icons")
local settings = require("settings")

local function pct_severity(v)
  if     v > 90 then return 4
  elseif v > 75 then return 3
  elseif v > 50 then return 2
  else               return 1
  end
end

local function temp_severity(v)
  if     v > 80 then return 4
  elseif v > 65 then return 3
  elseif v > 50 then return 2
  else               return 1
  end
end

local function level_color(s)
  if     s >= 4 then return colors.red
  elseif s >= 3 then return colors.orange
  elseif s >= 2 then return colors.yellow
  else               return colors.white
  end
end

local function format_rate(bps)
  if bps < 1024              then return string.format("%dB", bps) end
  if bps < 1024 * 1024       then return string.format("%dK", math.floor(bps / 1024 + 0.5)) end
  if bps < 1024 * 1024 * 1024 then return string.format("%.1fM", bps / (1024 * 1024)) end
  return string.format("%.1fG", bps / (1024 * 1024 * 1024))
end

local modes    = { "ram", "cpu", "heat", "disk", "net", "all" }
local mode_idx = 1
local current  = { cpu = 0, mem = 0, temp = 0, disk = 0, net_in = 0, net_out = 0 }
local net_prev = { ibytes = nil, obytes = nil, time = nil }
local net_iface = nil   -- cached; rarely changes
local disk_tick = 0     -- throttle disk to ~every 60 s (20 × 3 s ticks)

local function make_sub(name, glyph)
  return sbar.add("item", "system_stats." .. name, {
    position = "right",
    drawing  = false,
    icon = {
      string = glyph,
      color  = colors.white,
      font = {
        family = settings.font.icons,
        style  = settings.font.style_map["Regular"],
        size   = 18.0,
      },
    },
    label = {
      color = colors.white,
      font  = { family = settings.font.icons, size = 16.0 },
    },
  })
end

local items = {}
items.net  = make_sub("net",  icons.net_down)
items.disk = make_sub("disk", icons.disk)
items.mem  = make_sub("mem",  icons.memory)
items.temp = make_sub("temp", icons.temp)
items.cpu  = make_sub("cpu",  icons.cpu)

local driver = sbar.add("item", "system_stats.driver", {
  drawing     = false,
  updates     = true,
  update_freq = 3,
})

local mode_to_items = {
  ram  = { "mem" },
  cpu  = { "cpu" },
  heat = { "temp" },
  disk = { "disk" },
  net  = { "net" },
  all  = { "cpu", "temp", "mem", "disk", "net" },
}

local function set_visibility()
  local visible = {}
  for _, name in ipairs(mode_to_items[modes[mode_idx]]) do visible[name] = true end
  for name, item in pairs(items) do
    item:set({ drawing = visible[name] or false })
  end
end

local function do_net(iface)
  local now = os.time()
  sbar.exec("netstat -bn -I " .. iface .. " | awk 'NR==2 {print $7, $10}'", function(out)
    local ib, ob = out:match("(%d+)%s+(%d+)")
    if not ib then return end
    ib, ob = tonumber(ib), tonumber(ob)
    if net_prev.ibytes and net_prev.time then
      local dt = now - net_prev.time
      if dt > 0 then
        current.net_in  = math.max(0, (ib - net_prev.ibytes) / dt)
        current.net_out = math.max(0, (ob - net_prev.obytes) / dt)
      end
    end
    net_prev.ibytes, net_prev.obytes, net_prev.time = ib, ob, now
    items.net:set({
      label = {
        string = format_rate(current.net_in) .. "  " ..
                 icons.net_up .. " " .. format_rate(current.net_out),
        color  = colors.white,
      },
    })
  end)
end

driver:subscribe({ "routine", "forced" }, function()
  sbar.exec(
    [[top -l 1 -n 0 | awk '/CPU usage/ {gsub("%","",$3); gsub("%","",$5); printf "%.0f", $3 + $5}']],
    function(out)
      current.cpu = tonumber(out) or 0
      local c = level_color(pct_severity(current.cpu))
      items.cpu:set({ icon = { color = c }, label = { string = current.cpu .. "%", color = c } })
    end
  )
  sbar.exec(
    [[vm_stat | awk '/Pages active/{a=$3}/Pages wired/{w=$4}/Pages free/{f=$3}/Pages inactive/{i=$3} END{t=a+w+f+i; printf "%d", (t>0)?(a+w)/t*100:0}']],
    function(out)
      current.mem = tonumber(out) or 0
      local c = level_color(pct_severity(current.mem))
      items.mem:set({ icon = { color = c }, label = { string = current.mem .. "%", color = c } })
    end
  )
  -- Reads the latest sample produced by the macmon-pipe launchd agent
  -- (see users/bartjan/sketchybar.nix). Avoids re-spawning macmon every tick.
  sbar.exec(
    [[jq -r '.temp.cpu_temp_avg | round' /tmp/macmon.json 2>/dev/null]],
    function(out)
      current.temp = tonumber(out) or 0
      local c = level_color(temp_severity(current.temp))
      items.temp:set({ icon = { color = c }, label = { string = current.temp .. "°", color = c } })
    end
  )

  -- Disk is slow-moving; only query every ~60 s.
  disk_tick = disk_tick + 1
  if disk_tick % 20 == 1 then
    sbar.exec(
      [[df -k /System/Volumes/Data | awk 'NR==2 {gsub("%","",$5); print $5}']],
      function(out)
        current.disk = tonumber(out) or 0
        local c = level_color(pct_severity(current.disk))
        items.disk:set({ icon = { color = c }, label = { string = current.disk .. "%", color = c } })
      end
    )
  end

  -- Cache the default interface; re-resolve only when missing.
  if net_iface then
    do_net(net_iface)
  else
    sbar.exec([[route -n get default 2>/dev/null | awk '/interface:/ {print $2}']], function(out)
      local iface = out:match("^%s*(.-)%s*$")
      if iface and #iface > 0 then
        net_iface = iface
        do_net(iface)
      end
    end)
  end
end)

local function toggle()
  mode_idx = (mode_idx % #modes) + 1
  set_visibility()
end

for _, item in pairs(items) do
  item:subscribe("mouse.clicked", function() toggle() end)
end

set_visibility()
