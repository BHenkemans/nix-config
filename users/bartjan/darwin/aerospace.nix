{ pkgs, ... }:
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    settings = {
      "after-startup-command" = [ ];
      "start-at-login" = true;

      # Normalizations
      "enable-normalization-flatten-containers" = true;
      "enable-normalization-opposite-orientation-for-nested-containers" = true;

      "accordion-padding" = 0;
      "default-root-container-layout" = "tiles";
      "default-root-container-orientation" = "auto";

      "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];
      "automatically-unhide-macos-hidden-apps" = true;

      # Sketchybar integration. Use a small bash script from /nix/store rather
      # than booting a full zsh per workspace switch.
      "exec-on-workspace-change" = [
        "${pkgs.writeShellScript "aerospace-sb-trigger" ''
          exec ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change \
            FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE" \
            PREV_WORKSPACE="$AEROSPACE_PREV_WORKSPACE"
        ''}"
      ];
      key-mapping = {
        preset = "qwerty";
      };

      gaps = {
        inner.horizontal = 25;
        inner.vertical = 25;
        outer.left = 25;
        outer.bottom = 25;
        outer.right = 25;
        # Nix mixed-type lists are perfectly fine and map directly to TOML
        outer.top = [
          { monitor.Built-in = 35; }
          { monitor."^LG" = 65; }
          { monitor.secondary = 65; }
          50
        ];
      };

      "workspace-to-monitor-force-assignment" = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
      };

      mode.main.binding = {
        "alt-f" = "fullscreen";

        "alt-slash" = "layout tiles horizontal vertical";
        "alt-comma" = "layout accordion horizontal vertical";

        "alt-left" = "focus left";
        "alt-down" = "focus down";
        "alt-up" = "focus up";
        "alt-right" = "focus right";

        "alt-shift-left" = "move left";
        "alt-shift-down" = "move down";
        "alt-shift-up" = "move up";
        "alt-shift-right" = "move right";

        "alt-minus" = "resize smart -50";
        "alt-equal" = "resize smart +50";

        "alt-1" = "workspace 1";
        "alt-2" = "workspace 2";
        "alt-3" = "workspace 3";
        "alt-4" = "workspace 4";
        "alt-5" = "workspace 5";
        "alt-6" = "workspace 6";
        "alt-7" = "workspace 7";
        "alt-8" = "workspace 8";
        "alt-9" = "workspace 9";

        "alt-shift-1" = "move-node-to-workspace 1 --focus-follows-window";
        "alt-shift-2" = "move-node-to-workspace 2 --focus-follows-window";
        "alt-shift-3" = "move-node-to-workspace 3 --focus-follows-window";
        "alt-shift-4" = "move-node-to-workspace 4 --focus-follows-window";
        "alt-shift-5" = "move-node-to-workspace 5 --focus-follows-window";
        "alt-shift-6" = "move-node-to-workspace 6 --focus-follows-window";
        "alt-shift-7" = "move-node-to-workspace 7 --focus-follows-window";
        "alt-shift-8" = "move-node-to-workspace 8 --focus-follows-window";
        "alt-shift-9" = "move-node-to-workspace 9 --focus-follows-window";

        "alt-tab" = "workspace-back-and-forth";
        "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";

        "alt-shift-semicolon" = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        "alt-shift-r" = [
          "flatten-workspace-tree"
          "mode main"
        ]; # reset layout
        f = [
          "layout floating tiling"
          "mode main"
        ]; # Toggle between floating and tiling layout
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        "alt-shift-left" = [
          "join-with left"
          "mode main"
        ];
        "alt-shift-down" = [
          "join-with down"
          "mode main"
        ];
        "alt-shift-up" = [
          "join-with up"
          "mode main"
        ];
        "alt-shift-right" = [
          "join-with right"
          "mode main"
        ];

        down = "volume down";
        up = "volume up";
        "shift-down" = [
          "volume set 0"
          "mode main"
        ];
      };
    };
  };
}
