{ pkgs, lib, ...}: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.git
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.protonmail-desktop
      pkgs.protonmail-bridge
      pkgs.utm
      pkgs.claude-code
      pkgs.yubikey-manager
      pkgs.thunderbird
      pkgs.slack
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # These are packages which are installed using brew
      pkgs.eduvpn-client
    ];
}
