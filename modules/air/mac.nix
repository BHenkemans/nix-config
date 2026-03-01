{ agenix, config, pkgs, ... }:
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
        ApplePressAndHoldEnabled = false;
        AppleICUForce24HourTime = true;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        show-recents = false;
        mouse-over-hilite-stack = false;
        orientation = "left";
        tilesize = 32;
      };
      finder = {
        _FXShowPosixPathInTitle = false;
        FXPreferredViewStyle = "clmv";
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      loginwindow.GuestEnabled = false;
    };
  };
}