{ lib, ... }:
{
  imports = [
    ./aerospace.nix
    ./firefox.nix
    ./git.nix
    ./nvim.nix
    ./protonmail-bridge.nix
    ./sketchybar.nix
    ./sops.nix
    ./terminal.nix
    ./vscode.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  home.homeDirectory = lib.mkForce "/Users/bartjan";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
