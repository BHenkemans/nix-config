{ pkgs, ... } : {
  imports = [
    ./nix.nix
    ./sops.nix
    ./ssh.nix
    ./unconfigured_packages.nix
    ./users.nix
  ];
}
