{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.sops ];
  sops = {
    validateSopsFiles = true;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = if pkgs.stdenv.isDarwin then "/var/lib/sops-nix/key.txt" else "/etc/sops/key";
      generateKey = true;
    };
  };
}
