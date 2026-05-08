{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    lua5_5
    macmon
    sbarlua
    sketchybar-app-font
    nerd-fonts.hack
  ];

  programs.sketchybar = {
    enable = true;
    service.enable = true;
  };

  home.file.".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # launchd starts sketchybar with a minimal PATH; nix-installed tools
      # (aerospace, jq, ...) need to be visible to scripts spawned from lua.
      export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
      export LUA_CPATH="${pkgs.sbarlua}/lib/lua/5.5/?.so;;"
      export SKETCHYBAR_APP_FONT_LUA="${pkgs.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua"
      # Override IP-based geolocation (wrong on VPN); change here to relocate.
      export WEATHER_LOCATION="Eindhoven"
      exec ${pkgs.lua5_5}/bin/lua "$HOME/.config/sketchybar/init.lua"
    '';
  };

  home.file.".config/sketchybar" = {
    source = ./assets/sketchybar;
    recursive = true;
    executable = true;
  };
}
