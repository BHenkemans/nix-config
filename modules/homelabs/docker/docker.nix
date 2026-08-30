{ config, lib, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # The container units are otherwise byte-identical between rebuilds, so
  # systemd never restarts them and the `pull = "newer"` policy never runs.
  # Tying them to the config revision makes every build from a new commit
  # restart the containers, which is what re-checks the registry.
  systemd.services = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "podman-${name}" {
      restartTriggers = [ (toString config.system.configurationRevision) ];
    }
  ) config.virtualisation.oci-containers.containers;
}
