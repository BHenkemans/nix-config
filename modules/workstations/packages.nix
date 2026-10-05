{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      vim
      git
      signal-desktop
      spotify
      ansible
      claude-code
      yubikey-manager
      thunderbird
      jetbrains.rust-rover
      jetbrains.idea
      jetbrains.phpstorm
      rustup
      zed-editor
      nil
      nixd
      nixos-rebuild
      netbird
      kotlin
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full xetex;
      })
      python315
      just
      rust-analyzer
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
