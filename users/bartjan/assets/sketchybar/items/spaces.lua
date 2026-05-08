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

local function workspace_apps(ws)
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

local items = {}
local current = focused_workspace()

for _, sid in ipairs(read_lines("aerospace list-workspaces --all")) do
  local apps = workspace_apps(sid)
  local is_focused = (sid == current)
  local space = sbar.add("item", "space." .. sid, {
    position = "left",
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

local function refresh(sid, is_focused)
  local item = items[sid]
  if not item then return end
  local apps = workspace_apps(sid)
  item:set({
    drawing    = is_focused or #apps > 0,
    label      = { string = render_apps(apps) },
    background = { color = bg_color(is_focused) },
  })
end

local watcher = sbar.add("item", "spaces.watcher", {
  drawing = false,
  updates = true,
})

watcher:subscribe("aerospace_workspace_change", function(env)
  local cur, prev = env.FOCUSED_WORKSPACE, env.PREV_WORKSPACE
  for sid, item in pairs(items) do
    if sid ~= cur and sid ~= prev then
      item:set({ background = { color = bg_color(false) } })
    end
  end
  if prev then refresh(prev, false) end
  if cur  then refresh(cur,  true)  end
end)

watcher:subscribe("front_app_switched", function()
  local cur = focused_workspace()
  if cur then refresh(cur, true) end
end)
