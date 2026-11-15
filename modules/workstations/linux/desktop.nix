{ pkgs, ... }:
{
  # niri with its built-in default config. The nixpkgs module already wires up
  # the portals, gnome-keyring and the wayland session; niri starts
  # xwayland-satellite on its own when it is on PATH.
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    fuzzel # Mod+D in niri's default config
    swaylock # Super+Alt+L in niri's default config
    waybar # spawned at startup by niri's default config
    xwayland-satellite
    wl-clipboard
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # swaylock authenticates against PAM; without this entry it can never unlock.
  security.pam.services.swaylock = { };

  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true;
}
