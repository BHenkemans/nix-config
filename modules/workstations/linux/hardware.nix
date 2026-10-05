{ pkgs, ... }:
{
  # Intel integrated graphics. nixos-hardware's common-cpu-intel pulls in the
  # shared intel GPU module and microcode; these two options are the Kaby Lake
  # (Gen 9.5, HD 630) specifics it leaves at their Gen12+ defaults.
  hardware.intelgpu = {
    computeRuntime = "legacy"; # Gen8–11
    vaapiDriver = "intel-media-driver";
    # mediaRuntime is deliberately left at its default. The Gen8–11 value
    # would be "intel-media-sdk", but that package is EOL and marked insecure
    # in nixpkgs. Media SDK is a separate API from VAAPI; hardware decode via
    # intel-media-driver (set above) is what actually gets used here.
  };

  boot.kernelParams = [
    "i915.enable_guc=2" # GuC + HuC firmware: better media offload and power
    "i915.enable_fbc=1" # framebuffer compression, saves power on eDP
    # "i915.enable_psr=2" is the other half of nixos-hardware's kaby-lake
    # profile. Left off deliberately — panel self-refresh causes visible
    # flicker on a number of Kaby Lake panels. Turn it on if the battery
    # figures matter more than the risk.
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # laptop: don't wake the radio unless asked
  };

  networking.networkmanager.enable = true;

  # Firmware updates: the ZBook is well covered by LVFS.
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    pciutils
    usbutils
  ];
}
