{ self, ... }:
{
  imports = [
    ./disko.nix
    ../../modules
    ../../modules/workstations
    ../../modules/workstations/linux
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      # No boot-time kernel cmdline editor: with an encrypted root it is not a
      # root-shell hole the way it is on the docker host, but it still lets
      # anyone with the LUKS passphrase bypass the init.
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
    # Real hardware: NVMe + USB, unlike the docker host's virtio set.
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  time.timeZone = "Europe/Amsterdam";
  networking.hostName = "laptop";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = "26.05";
}
