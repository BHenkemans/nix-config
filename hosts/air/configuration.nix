{ self, pkgs, config, ... }: {
  imports = [
    ../../modules
    ../../modules/workstations
    ../../modules/workstations/air
  ];

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Garbage
  nix.gc.automatic = true;

  time.timeZone = "Europe/Amsterdam";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
