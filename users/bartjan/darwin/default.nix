_: {
  # macOS-only user config. These modules carry
  # `lib.hm.assertions.assertPlatform … lib.platforms.darwin` upstream, and
  # borg.nix/sketchybar.nix additionally depend on launchd agents, ~/Library
  # paths and macmon (Apple Silicon), so none of them have a Linux counterpart.
  imports = [
    ./aerospace.nix
    ./borg.nix
    ./sketchybar.nix
    ./sops.nix
  ];
}
