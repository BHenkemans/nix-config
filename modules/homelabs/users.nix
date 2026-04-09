{ pkgs, config, ... }: {
  sops.secrets.abartjan-password-u.neededForUsers = true;

  users = {
    mutableUsers = false;
    users.abartjan = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets.abartjan-password-u.path;
      openssh.authorizedKeys.keyFiles = [
        (builtins.fetchurl {
          url = "https://github.com/BHenkemans.keys";
          sha256 = "sha256:10hsihj4i5q06dw3i52q9qzyvmvpx1j51r7crnk2a5md8ha8bkx3";
        })
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
