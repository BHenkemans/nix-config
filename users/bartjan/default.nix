{ pkgs, lib, ... } : {
  imports = [
    ./aerospace.nix
    ./firefox.nix
    ./git.nix
    ./nvim.nix 
    ./sops.nix
    ./vscode.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };
  
  home.homeDirectory = lib.mkForce (if pkgs.stdenv.isDarwin then "/Users/bartjan" else "/home/bartjan");
  home.stateVersion = "25.11"; 
  programs.home-manager.enable = true;
}