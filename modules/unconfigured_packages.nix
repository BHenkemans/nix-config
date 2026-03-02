{ pkgs, lib, ...}: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.git
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.protonmail-desktop
      pkgs.utm
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # These are packages which are installed using brew
      pkgs.eduvpn-client
    ];
  
}
