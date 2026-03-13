{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];
  programs = {
    alacritty = {
      enable = true;
      theme = "nordic";
      settings = {
        window = {
          opacity = 0.90;
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
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (builtins.readFile "${pkgs.oh-my-posh}/share/oh-my-posh/themes/agnoster.omp.json");
    };
  };
}