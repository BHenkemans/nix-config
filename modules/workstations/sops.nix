{ inputs, ... }:
{
  sops.defaultSopsFile = inputs.sops-repo + "/secrets.yaml";
}
