{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.meslo-lg
    tmux-cssh
    zoxide
  ];

  programs = {
    alacritty = {
      enable = true;
      theme = "nordic";
      settings = {
        window = {
          opacity = 0.85;
        };
        font = {
          normal = {
            family = "MesloLGM Nerd Font";
            style = "Regular";
          };
          size = 18;
        };
      };
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ssh-add-key = "eval \"$(ssh-agent -s)\" && ssh-add";
      };
      initContent = ''
        if [ -z "$TMUX" ] && [ -n "$PS1" ] && [ -n "$ALACRITTY_WINDOW_ID" ] && [ -z "$TERM_PROGRAM" ]; then
          tmux attach || tmux new-session
        fi
      '';
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
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}
