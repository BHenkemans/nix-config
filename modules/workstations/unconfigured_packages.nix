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
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full xetex;
      })
      python315
      just 
      rustup
      rust-analyzer
      btop
      nodejs
    ]
    ++ lib.optionals stdenv.isLinux [
      # These are packages which are installed using brew
      slack
      eduvpn-client
      mattermost-desktop
    ];
}
