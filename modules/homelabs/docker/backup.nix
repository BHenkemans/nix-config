{ config, lib, ... }:
let
  cfg = config.homelab.backups;

  stagingBase = "/var/lib/borg-staging";

  # Shared across every backup job.
  storageBoxRsh =
    "ssh -p 23 -i /etc/ssh/ssh_host_ed25519_key -o StrictHostKeyChecking=accept-new";
  pruneKeep = {
    daily = 7;
    weekly = 4;
    monthly = 6;
  };
in
{
  options.homelab.backups = lib.mkOption {
    default = { };
    description = ''
      Borg backups, one entry per Storage Box sub-account. Each entry becomes
      its own `services.borgbackup.jobs.<name>` with its own repo and
      passphrase (sops secret `borg/<name>`).
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            repo = lib.mkOption {
              type = lib.types.str;
              description = "Borg repo URL for this backup's Storage Box sub-account.";
            };
            paths = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Data paths included in this backup.";
            };
            exclude = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Patterns excluded from this backup.";
            };
            preHook = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Shell run before the backup, e.g. to stage DB snapshots.";
            };
            stagingDir = lib.mkOption {
              type = lib.types.str;
              default = "${stagingBase}/${name}";
              readOnly = true;
              description = ''
                Directory backed up alongside this backup's data. Services
                stage consistent snapshots here from their `preHook`.
              '';
            };
          };
        }
      )
    );
  };

  config = {
    # One passphrase secret per backup.
    sops.secrets = lib.mapAttrs' (name: _: lib.nameValuePair "borg/${name}" { }) cfg;

    # Staging dirs (one per backup, under a shared base).
    systemd.tmpfiles.rules = [
      "d ${stagingBase} 0700 root root -"
    ]
    ++ lib.mapAttrsToList (_: b: "d ${b.stagingDir} 0700 root root -") cfg;

    # One borg job per backup / sub-account.
    services.borgbackup.jobs = lib.mapAttrs (name: b: {
      paths = b.paths ++ [ b.stagingDir ];
      exclude = b.exclude;
      preHook = b.preHook;
      repo = b.repo;
      doInit = true;

      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/${name}".path}";
      };

      # All sub-accounts authorise this host's SSH key.
      environment.BORG_RSH = storageBoxRsh;

      compression = "auto,zstd";
      startAt = "daily";
      readWritePaths = [ b.stagingDir ];
      prune.keep = pruneKeep;
    }) cfg;

    # Catch up a missed run if the host was off at the scheduled time.
    systemd.timers = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "borgbackup-job-${name}" {
        timerConfig.Persistent = true;
      }
    ) cfg;
  };
}
