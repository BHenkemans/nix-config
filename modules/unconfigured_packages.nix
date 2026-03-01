{ pkgs, lib, ...}: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.git
      pkgs.signal-desktop
      pkgs.spotify
      pkgs.protonmail-desktop
      #pkgs.zotero
      # (pkgs.texlive.combine {
      # inherit (pkgs.texlive) scheme-full xetex;
      # })
    ] ++ lib.optional pkgs.stdenv.isLinux [
      # These are packages which are installed using brew
      pkgs.eduvpn-client
    ];
  
}