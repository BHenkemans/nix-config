{ pkgs, ... }:
{
  # niri, a scrollable-tiling Wayland compositor. The nixpkgs module
  # (nixos/modules/programs/wayland/niri.nix) already wires up xdg-desktop-portal
  # (gnome + gtk backends), gnome-keyring, displayManager.sessionPackages and
  # the systemd user service, so there is deliberately little here.
  programs.niri.enable = true;

  # niri's nixpkgs module passes enableXWayland = false to wayland-session, so
  # X11 clients need xwayland-satellite. The shared package list ships JetBrains
  # IDEs, which still want it.
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    wl-clipboard
  ];

  # Login manager. tuigreet reads the wayland-sessions that programs.niri
  # registers via services.displayManager.sessionPackages. greetd is chosen over
  # GDM because GDM drags in most of GNOME for no benefit here.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };

  # Audio. Same stack the (unmerged) nixrdp module used.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # swaylock authenticates against PAM; without this entry it can never unlock.
  security.pam.services.swaylock = { };

  security.polkit.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
  ];
}
