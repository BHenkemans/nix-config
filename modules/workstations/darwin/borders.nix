_: {
  # AeroSpace draws no window decorations by design, so focus is invisible with
  # large gaps. JankyBorders fills that gap; colours track the sketchybar
  # palette in users/bartjan/assets/sketchybar/colors.lua.
  services.jankyborders = {
    enable = true;

    active_color = "0xff76cce0"; # colors.blue
    inactive_color = "0xff3e4150"; # colors.bg2

    width = 5.0;
    style = "round";

    # Draw underneath the window so the border never overlaps content; the
    # 25px AeroSpace gaps leave plenty of room for it to show.
    order = "below";

    hidpi = true;
    # Resolve focus through the accessibility API instead of "frontmost app",
    # which is what AeroSpace actually focuses.
    ax_focus = true;
  };
}
