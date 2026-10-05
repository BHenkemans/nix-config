{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      vim
      git
      signal-desktop
      spotify
      # claude-code
      yubikey-manager
      thunderbird
      jetbrains.rust-rover
      jetbrains.phpstorm
      rustup
      nixd
      nixos-rebuild
      netbird
      kotlin
      python315
      just
      btop
    ]
    ++ lib.optionals stdenv.isDarwin [
      # Darwin-only in nixpkgs; evaluating it on Linux fails.
      utm
    ]
    ++ lib.optionals stdenv.isLinux [
      # These are packages which are installed using brew on macOS
      slack
      eduvpn-client
      mattermost-desktop
    ];
}
