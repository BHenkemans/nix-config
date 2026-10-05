{ config, ... }:
let
  user = "bartjan";
in
{
  # Linux counterpart to users/bartjan/darwin/sops.nix.
  #
  # On macOS Home Manager decrypts these itself, because the personal age
  # identity lives inside the home directory where a user-level service can
  # read it. On NixOS the only enrolled identity is /etc/sops/key (root-owned,
  # 0600), so a Home-Manager-level sops can never decrypt anything here.
  #
  # Instead the *system* layer decrypts the same secrets and hands ownership to
  # the user; users/bartjan/linux/ssh.nix then symlinks them into ~/.ssh. This
  # keeps the personal master key off the laptop entirely, which also means the
  # host stays individually revocable (drop it from .sops.yaml + updatekeys).
  #
  # Deliberately no `path = "~/.ssh/..."` override: sops-install-secrets calls
  # os.MkdirTemp(dirname(path)) and does not create parent directories, so
  # pointing it at ~/.ssh before that directory exists fails the activation.
  # Leaving the default /run/secrets path and symlinking from Home Manager
  # sidesteps the ordering problem.
  sops.secrets = {
    "private_keys/${user}" = {
      owner = user;
      inherit (config.users.users.${user}) group;
      mode = "0400";
    };
    "private_keys/${user}-sk" = {
      owner = user;
      inherit (config.users.users.${user}) group;
      mode = "0400";
    };
  };
}
