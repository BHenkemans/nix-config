{ inputs, ... }:
{
  sops.defaultSopsFile = inputs.sops-repo + "/homelab.yaml";
}
