_: {
  imports = [
    ./disko.nix
    ../../modules/default.nix
    ../../modules/homelabs
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "sd_mod" ];
  };
  system.stateVersion = "26.05";
} 
