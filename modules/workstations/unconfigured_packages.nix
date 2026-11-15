{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      vim
      git
      signal-desktop
      spotify
      utm
      # claude-code
      yubikey-manager
      thunderbird
      jetbrains.rust-rover
      rustup
      nixd
      nixos-rebuild
      python315
      just
      btop
    ]
    ++ lib.optionals stdenv.isLinux [
      # These are packages which are installed using brew
      slack
      eduvpn-client
      mattermost-desktop
    ];
}
