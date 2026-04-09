{ pkgs, ... } : {
  imports = [
    ./nix.nix
    ./ssh.nix
    ./unconfigured_packages.nix
    ./users.nix
  ];
}
