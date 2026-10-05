_: {
  # Linux counterpart to ./darwin. Imported by hosts/<host>/configuration.nix
  # alongside ../../modules/workstations.
  imports = [
    ./desktop.nix
    ./hardware.nix
    ./power.nix
    ./sops.nix
  ];
}
