{ pkgs, lib, ...}: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.git
    ];
}
