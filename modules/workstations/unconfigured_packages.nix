{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      vim
      git
      signal-desktop
      spotify
      protonmail-bridge
      utm
      ansible
      claude-code
      yubikey-manager
      thunderbird
      jetbrains.rust-rover
      rustup
      zed-editor
      nil
      nixd
      slack
    ]
    ++ lib.optionals stdenv.isLinux [
      # These are packages which are installed using brew
      eduvpn-client
      mattermost-desktop
    ];
}
