_: {
  # Linux-only user config. Counterpart to ../darwin; added alongside
  # ../../users/bartjan by flake.nix.
  imports = [
    ./niri.nix
    ./ssh.nix
  ];
}
