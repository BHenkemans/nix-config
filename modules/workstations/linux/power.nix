{ lib, ... }:
{
  # nixos-hardware's common-pc-laptop already turns TLP on by default and
  # common-pc-laptop-ssd enables fstrim; both are lib.mkDefault, so this file
  # only has to avoid contradicting them and add the laptop-specific bits.
  #
  # power-profiles-daemon stays off: it conflicts with TLP, and its main
  # benefit is a GNOME/KDE applet we don't have under niri.
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true; # Intel-specific thermal governor
  services.upower.enable = true; # battery state for the bar

  # No swap partition (see hosts/laptop/disko.nix), so compressed RAM swap
  # instead. This rules out hibernation — suspend-to-RAM only.
  zramSwap.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    # Docked with an external display attached, closing the lid shouldn't
    # suspend the machine.
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Keep the store lean on a 238G disk.
  nix.optimise.automatic = lib.mkDefault true;
}
