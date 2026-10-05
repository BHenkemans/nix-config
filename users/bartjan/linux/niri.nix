{ pkgs, ... }:
let
  # Sonokai palette, shared with the sketchybar/jankyborders setup on air.
  # See ../darwin/assets/sketchybar/colors.lua.
  colors = {
    bg = "#2c2e34";
    bg2 = "#3e4150";
    fg = "#e2e2e3";
    blue = "#76cce0";
    green = "#9ed072";
    yellow = "#e7c664";
    red = "#fc5d7c";
    grey = "#7f8490";
  };
in
{
  # niri itself is enabled system-wide (modules/workstations/linux/desktop.nix);
  # Home Manager has no niri module, so the config is shipped as KDL.
  xdg.configFile."niri/config.kdl".source = ./assets/niri/config.kdl;

  home.packages = with pkgs; [
    brightnessctl
    playerctl
    grim
    slurp
    wl-clipboard
    libnotify
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "MesloLGM Nerd Font:size=14";
        terminal = "${pkgs.alacritty}/bin/alacritty -e";
        layer = "overlay";
        width = 45;
      };
      colors = {
        background = "2c2e34f0";
        text = "e2e2e3ff";
        match = "76cce0ff";
        selection = "3e4150ff";
        selection-text = "e2e2e3ff";
        border = "76cce0ff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "MesloLGM Nerd Font 12";
      background-color = "${colors.bg}f0";
      text-color = colors.fg;
      border-color = colors.blue;
      border-size = 2;
      border-radius = 8;
      default-timeout = 5000;
      padding = "10";
      margin = "10";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "181819";
      ring-color = "76cce0";
      key-hl-color = "9ed072";
      line-color = "00000000";
      inside-color = "2c2e34";
      text-color = "e2e2e3";
      show-failed-attempts = true;
      indicator-radius = 100;
      ignore-empty-password = true;
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
    };
  };

  services.cliphist.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 8;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "cpu"
        "memory"
        "battery"
        "network"
        "tray"
      ];

      "niri/workspaces".format = "{value}";
      "niri/window" = {
        format = "{}";
        max-length = 60;
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      cpu.format = " {usage}%";
      memory.format = " {}%";

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = " ";
        format-disconnected = "睊";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = " ";
        format-icons.default = [
          ""
          ""
          ""
        ];
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
    };

    style = ''
      * {
        font-family: "MesloLGM Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: ${colors.bg};
        color: ${colors.fg};
      }

      #workspaces button {
        padding: 0 8px;
        color: ${colors.grey};
        background: transparent;
      }

      #workspaces button.focused,
      #workspaces button.active {
        color: ${colors.bg};
        background: ${colors.blue};
        border-radius: 6px;
      }

      #window {
        color: ${colors.grey};
        padding: 0 8px;
      }

      #clock, #cpu, #memory, #battery, #network, #pulseaudio, #tray {
        padding: 0 10px;
        color: ${colors.fg};
      }

      #battery.warning  { color: ${colors.yellow}; }
      #battery.critical { color: ${colors.red}; }
      #battery.charging { color: ${colors.green}; }
    '';
  };
}
