_: {
  nix = {
    # Reclaim disk space: collect garbage weekly, keep 30 days of roots.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Hard-link identical files in the store after each build.
    optimise.automatic = true;
  };
}
