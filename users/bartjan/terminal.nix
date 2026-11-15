{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.meslo-lg
    tmux-cssh
    zoxide
  ];

  programs = {
    ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      settings = {
        theme = "Nord";
        background-opacity = 0.85;
        font-family = "MesloLGM Nerd Font";
        font-size = 18;
      };
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -lah";
        ssh-add-key = "eval \"$(ssh-agent -s)\" && ssh-add";
        euc-share = "mkdir -p /tmp/crypt && rclone mount euc2027-crypt:/ /tmp/crypt --daemon --vfs-cache-mode writes";
      };
      initContent = lib.mkMerge [
        ''
          if [ -z "$TMUX" ] && [ -n "$PS1" ] && [ "$TERM_PROGRAM" = "ghostty" ]; then
            tmux attach || tmux new-session
          fi
        ''
        # zoxide must be initialized last, after other prompt/chpwd hooks
        (lib.mkOrder 2000 ''
          eval "$(${lib.getExe pkgs.zoxide} init zsh --cmd cd)"
        '')
      ];
    };
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        catppuccin
      ];
      #shortcut = "Space";
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g mouse on
        set -g base-index 1
      '';
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (
        builtins.readFile "${pkgs.oh-my-posh}/share/oh-my-posh/themes/agnoster.omp.json"
      );
    };
    zoxide = {
      enable = true;
      # Initialized manually at the end of zsh initContent
      enableZshIntegration = false;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
