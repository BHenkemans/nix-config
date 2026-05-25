{ config, pkgs, ... }:
{
  # PAT (classic: `admin:org`, or fine-grained: org "Self-hosted runners: R/W")
  # in homelab.yaml. Ephemeral runners need a PAT, not a registration token,
  # so the NixOS wrapper can mint a fresh registration before each job.
  sops.secrets."github-runner/token" = { };

  services.github-runners.gehack-docker = {
    enable = true;
    url = "https://github.com/GEHACK";
    tokenFile = config.sops.secrets."github-runner/token".path;
    ephemeral = true;
    replace = true;
    extraLabels = [
      "nixos"
      "homelab"
    ];
    extraPackages = with pkgs; [
      git
      gh
      cacert
    ];
  };
}
