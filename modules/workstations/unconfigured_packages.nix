{ pkgs, lib, ...}: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.git
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.protonmail-desktop
      pkgs.utm
      pkgs.ansible
      pkgs.claude-code
      pkgs.yubikey-manager
      pkgs.thunderbird
      pkgs.jetbrains.rust-rover
      pkgs.rustup
      pkgs.zed-editor
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # These are packages which are installed using brew
      pkgs.eduvpn-client
    ];
}
