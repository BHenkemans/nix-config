{
  pkgs,
  lib,
  config,
  ...
}:
{
  sops.secrets.bartjan-password.neededForUsers = true;

  # `shell = pkgs.zsh` below is only honoured on NixOS if zsh is also enabled
  # system-wide; nix-darwin has no such requirement but tolerates the option.
  programs.zsh.enable = true;

  users = {
    users.bartjan = {
      name = "bartjan";
      shell = pkgs.zsh;
      # Home Manager's NixOS/nix-darwin integration derives
      # `home.homeDirectory` from this. nix-darwin defaults it to null, which
      # is why users/bartjan used to hardcode the macOS path; setting it here
      # lets one user config serve both platforms. `createHome` stays false,
      # so this only records the path, it doesn't recreate the directory.
      home = if pkgs.stdenv.isDarwin then "/Users/bartjan" else "/home/bartjan";
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
      ];
      hashedPasswordFile = config.sops.secrets.bartjan-password.path;
    };
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    mutableUsers = false;
  };
}
