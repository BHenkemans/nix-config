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
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full xetex;
      })
      python315
      just 
      rustup
      rust-analyzer
      btop
    ]
    ++ lib.optionals stdenv.isLinux [
      # These are packages which are installed using brew
      eduvpn-client
      mattermost-desktop
    ];
}
