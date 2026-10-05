_: {
  # Shared across every workstation, macOS and Linux alike. The
  # platform-specific half (./darwin or ./linux) is imported by
  # hosts/<host>/configuration.nix.
  #
  # Dispatch stays in the host files on purpose: at the NixOS/nix-darwin level
  # `pkgs` is built from `nixpkgs.hostPlatform`, so branching on it inside
  # `imports` here would be an infinite-recursion trap. Platform conditionals
  # belong in the config bodies of the leaf modules below.
  imports = [
    ./netbird.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./users.nix
  ];
}
