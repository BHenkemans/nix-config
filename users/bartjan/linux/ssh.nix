{ config, ... }:
let
  # Decrypted by the system sops layer (modules/workstations/linux/sops.nix)
  # and chowned to this user, so the symlinks below resolve to files OpenSSH
  # will accept.
  secretsDir = "/run/secrets/private_keys";
in
{
  # mkOutOfStoreSymlink rather than a plain `source`: the target is produced at
  # activation time on the machine, so it must not be copied into the store
  # (which would put the private key in a world-readable /nix/store path).
  home.file.".ssh/id_ed25519".source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/bartjan";
  home.file.".ssh/id_ed25519_sk".source =
    config.lib.file.mkOutOfStoreSymlink "${secretsDir}/bartjan-sk";

  # Public halves are shipped from the repo rather than derived on the machine.
  #
  # git.nix needs ~/.ssh/id_ed25519.pub to exist (commit.gpgsign with
  # user.signingkey pointing at it), but id_ed25519 is passphrase-protected, so
  # `ssh-keygen -y` prompts and cannot run unattended — which is why the
  # generateSshPubKey activation script in users/bartjan/darwin/sops.nix never
  # actually produced this file. On air it has simply existed by hand since the
  # key was created; a fresh machine is where that gap shows up.
  #
  # A public key is not a secret, so committing it is both safe and simpler
  # than any amount of activation-time derivation.
  home.file.".ssh/id_ed25519.pub".source = ../keys/id_ed25519.pub;
  home.file.".ssh/id_ed25519_sk.pub".source = ../keys/id_ed25519_sk.pub;
}
