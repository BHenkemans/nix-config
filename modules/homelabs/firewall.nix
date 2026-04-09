{ ... }: {
  networking = {
    nftables = {
      enable = true;
      rulesetFile = ./assets/nftables.conf;
    };

    firewall.enable = false;
  };
}
