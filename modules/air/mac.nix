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
        ApplePressAndHoldEnabled = true;
        AppleICUForce24HourTime = true;
        KeyRepeat = 2;
        _HIHideMenuBar = true;
      };
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
        TrackpadThreeFingerDrag = true;
      };
      loginwindow.GuestEnabled = false;
    };
    #TODO implement hot corners
  };
}