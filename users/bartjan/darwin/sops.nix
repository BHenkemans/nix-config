{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # Darwin-only: this works because the personal age identity (age1n0k4lj…)
    # lives inside the home directory, so Home Manager — which runs as the
    # user — can read it. There is no Linux equivalent: the only enrolled
    # identity on a NixOS host is /etc/sops/key, which is root-owned, so the
    # Linux side deploys these same secrets from the *system* sops layer
    # instead. See modules/workstations/linux/sops.nix.
    age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = inputs.sops-repo + "/secrets.yaml";
    validateSopsFiles = true;
    secrets = {
      "private_keys/bartjan" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
      "private_keys/bartjan-sk" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_sk";
      };
    };
  };
  home.activation.generateSshPubKey = config.lib.dag.entryAfter [ "setupSops" ] ''
    # Check if private key exists AND public key does NOT exist
    if [ -f "${config.home.homeDirectory}/.ssh/id_ed25519" ] && [ ! -f "${config.home.homeDirectory}/.ssh/id_ed25519.pub" ]; then

      echo "Generating missing SSH public key..."

      # Extract the public key and write it to the .pub file
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -y -f "${config.home.homeDirectory}/.ssh/id_ed25519" > "${config.home.homeDirectory}/.ssh/id_ed25519.pub"

      # Ensure correct permissions for the public key
      $DRY_RUN_CMD chmod 0644 "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
    fi

    # Same for the security key (sk) variant — requires the FIDO2 key to be plugged in
    if [ -f "${config.home.homeDirectory}/.ssh/id_ed25519_sk" ] && [ ! -f "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub" ]; then

      echo "Generating missing SSH public key (sk)..."

      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -y -f "${config.home.homeDirectory}/.ssh/id_ed25519_sk" > "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub"

      $DRY_RUN_CMD chmod 0644 "${config.home.homeDirectory}/.ssh/id_ed25519_sk.pub"
    fi
  '';
}
