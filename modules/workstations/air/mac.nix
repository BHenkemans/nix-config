_:
let
  user = "bartjan";
in
{

  system = {
    primaryUser = user;
    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = false;
        ApplePressAndHoldEnabled = true;
        AppleICUForce24HourTime = true;
        KeyRepeat = 2;
        # Menu bar back now that SketchyBar is gone; OmniWM's workspace bar
        # overlaps it by default.
        _HIHideMenuBar = false;
      };
      # OmniWM requires "Displays have separate Spaces" (spans-displays = false).
      spaces.spans-displays = false;
      dock = {
        autohide = true;
        show-recents = false;
        mouse-over-hilite-stack = false;
        orientation = "right";
        tilesize = 24;
      };
      finder = {
        _FXShowPosixPathInTitle = false;
        FXPreferredViewStyle = "clmv";
      };
      trackpad = {
        Clicking = true;
        # Off: three fingers belong to OmniWM's column scrolling.
        TrackpadThreeFingerDrag = false;
      };
      loginwindow.GuestEnabled = false;
    };
    #TODO implement hot corners
  };
}
