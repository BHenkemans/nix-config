sbar = require("sketchybar")

sbar.add("event", "aerospace_workspace_change")

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

sbar.event_loop()
