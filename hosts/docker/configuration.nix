{ self, ... }:
{
  imports = [
    ./disko.nix
    ../../modules/default.nix
    ../../modules/homelabs
    ../../modules/homelabs/docker
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      # Disable the boot-time kernel cmdline editor — prevents trivial
      # local root via init=/bin/sh for anyone with console access.
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
    ];
  };
  time.timeZone = "Europe/Amsterdam";
  networking.hostName = "docker";

  # Git commit hash. Also drives the container restartTriggers in
  # modules/homelabs/docker/docker.nix.
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = "26.05";
}
