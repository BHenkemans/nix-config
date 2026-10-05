local colors = require("colors")

sbar.bar({
  position      = "top",
  height        = 38,
  color         = colors.with_alpha(colors.bar.bg, 0.6),
  blur_radius   = 30,
  padding_left  = 6,
  padding_right = 6,
  margin        = 0,
  corner_radius = 0,
  y_offset      = 0,
  shadow        = false,
})
