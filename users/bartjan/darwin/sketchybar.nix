{ pkgs, ... }:
let
  # Long-running macmon sampler. Re-spawning macmon every sketchybar tick
  # opens a fresh IOReport session 20×/min, which degrades badly across
  # sleep/wake. Run it once and have sketchybar read the latest sample
  # from a tiny single-line file that's atomically replaced each update.
  macmonRunner = pkgs.writeShellScript "macmon-pipe-runner" ''
    exec ${pkgs.macmon}/bin/macmon pipe -s 1000 \
      | while IFS= read -r line; do
          printf '%s\n' "$line" > /tmp/macmon.json.tmp \
            && mv /tmp/macmon.json.tmp /tmp/macmon.json
        done
  '';
in
{
  home.packages = with pkgs; [
    jq
    lua5_5
    macmon
    sbarlua
    sketchybar-app-font
    nerd-fonts.hack
  ];

  launchd.agents.macmon-pipe = {
    enable = true;
    config = {
      ProgramArguments = [ "${macmonRunner}" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardErrorPath = "/tmp/macmon-pipe.err.log";
    };
  };

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
