{ config, ... } : {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Bartjan Henkemans";
        email = "bartjan@henkemans.be";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      init.defaultBranch = "main";
    };
  };
}