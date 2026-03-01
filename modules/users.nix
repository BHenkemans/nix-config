{ pkgs, lib, config, ... }: {
  sops.secrets.bartjan-password.neededForUsers = true;
  
  users = {
    users.bartjan = {
      name = "bartjan"; 
      shell = pkgs.zsh;
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets.bartjan-password.path;
    };
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    mutableUsers = false; 
  };
}