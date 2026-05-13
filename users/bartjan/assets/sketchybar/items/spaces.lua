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

-- Blocking helpers — only called at init time, before event_loop().
local function read_lines(cmd)
  local h = io.popen(cmd)
  if not h then return {} end
  local out = {}
  for line in h:lines() do table.insert(out, line) end
  h:close()
  return out
end

local function focused_workspace()
  return read_lines("aerospace list-workspaces --focused")[1]
end

local function workspace_apps_sync(ws)
  local seen, apps = {}, {}
  for _, line in ipairs(read_lines("aerospace list-windows --workspace " .. ws .. " --format '%{app-name}'")) do
    local app = line:match("^%s*(.-)%s*$")
    if app and #app > 0 and not seen[app] then
      seen[app] = true
      table.insert(apps, app)
    end
  end
  return apps
end

-- Non-blocking helpers — used in event callbacks.
local function parse_app_output(out)
  local seen, apps = {}, {}
  for line in (out .. "\n"):gmatch("([^\n]*)\n") do
    local app = line:match("^%s*(.-)%s*$")
    if app and #app > 0 and not seen[app] then
      seen[app] = true
      table.insert(apps, app)
    end
  end
  return apps
end

local function render_apps(apps)
  local parts = {}
  for _, app in ipairs(apps) do
    table.insert(parts, app_icons[app] or app_icons["Default"] or ":default:")
  end
  return table.concat(parts, " ")
end

local function bg_color(is_focused)
  return is_focused
    and colors.with_alpha(colors.blue, 0.45)
    or  colors.with_alpha(colors.bg2, 0.30)
end

-- Aerospace's monitor-id orders by physical arrangement, but sketchybar's
-- `display` follows NSScreen order (1 = macOS main). Use aerospace's NSScreen
-- placeholder so workspaces land on the screen aerospace assigned them to.
local function build_display_map()
  local ws_display = {}
  for _, line in ipairs(read_lines(
    "aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}'"
  )) do
    local mid, nsid = line:match("^(%d+)%s+(%d+)$")
    if mid and nsid then
      for _, sid in ipairs(read_lines("aerospace list-workspaces --monitor " .. mid)) do
        ws_display[sid] = tonumber(nsid)
      end
    end
  end
  return ws_display
end

-- Async app-list refresh — returns immediately; updates item when exec finishes.
local function async_refresh(sid, is_focused, items)
  local item = items[sid]
  if not item then return end
  sbar.exec("aerospace list-windows --workspace " .. sid .. " --format '%{app-name}'", function(out)
    local apps = parse_app_output(out)
    item:set({
      drawing = is_focused or #apps > 0,
      label   = { string = render_apps(apps) },
    })
  end)
end

-- ── Initialisation (blocking is fine here, runs before event_loop) ───────────

local items = {}
local current_ws  = focused_workspace()   -- kept in sync; avoids subprocess on front_app_switched
local display_map = build_display_map()

for _, sid in ipairs(read_lines("aerospace list-workspaces --all")) do
  local apps       = workspace_apps_sync(sid)
  local is_focused = (sid == current_ws)
  local space = sbar.add("item", "space." .. sid, {
    position = "left",
    display  = display_map[sid] or 1,
    drawing  = is_focused or #apps > 0,
    icon = {
      string        = sid,
      padding_left  = 10,
      padding_right = 6,
      color         = colors.white,
      font = {
        family = settings.font.numbers,
        style  = settings.font.style_map["Bold"],
        size   = 16.0,
      },
    },
    label = {
      string        = render_apps(apps),
      padding_left  = 0,
      padding_right = 10,
      color         = colors.white,
      y_offset      = -1,
      font = {
        family = settings.font.app_icons,
        style  = "Regular",
        size   = 18.0,
      },
    },
    background = {
      color         = bg_color(is_focused),
      height        = 30,
      corner_radius = 6,
      border_width  = 0,
    },
    click_script = "aerospace workspace " .. sid,
  })
  items[sid] = space
end

-- ── Event subscriptions ───────────────────────────────────────────────────────

local watcher = sbar.add("item", "spaces.watcher", {
  drawing = false,
  updates = true,
})

watcher:subscribe("aerospace_workspace_change", function(env)
  local cur, prev = env.FOCUSED_WORKSPACE, env.PREV_WORKSPACE
  current_ws = cur

  -- Instant visual feedback: update highlights with no I/O.
  for sid, item in pairs(items) do
    item:set({ background = { color = bg_color(sid == cur) } })
  end
  if cur and items[cur] then
    items[cur]:set({ drawing = true })
  end

  -- Async: update app icons for the two affected workspaces.
  if prev then async_refresh(prev, false, items) end
  if cur  then async_refresh(cur,  true,  items) end
end)

watcher:subscribe("front_app_switched", function()
  -- current_ws is already known from the last workspace change event;
  -- no subprocess needed to find it.
  if current_ws then async_refresh(current_ws, true, items) end
end)

-- Reassign display indices on monitor plug/unplug or wake.
watcher:subscribe({ "display_change", "system_woke" }, function()
  local new_map = build_display_map()
  for sid, item in pairs(items) do
    item:set({ display = new_map[sid] or 1 })
  end
  display_map = new_map
end)
