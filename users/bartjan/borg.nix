{
  pkgs,
  config,
  lib,
  ...
}:
let
  repo = "ssh://u523666-sub3@u523666.your-storagebox.de:23/./borg-air";

  sshKey = config.sops.secrets."borg/ssh_key".path;
  passphraseFile = config.sops.secrets."borg/air".path;
  # Bootstrap-level fallback log (parent dir already exists): only catches
  # launchd/exec failures before the script sets up its own per-run log below.
  logFile = "${config.home.homeDirectory}/Library/Logs/borg-backup.log";
  # One timestamped log file per run is written under here; kept indefinitely.
  logDir = "${config.home.homeDirectory}/Library/Logs/borg-backup";

  # rclone remote holding the encrypted euc share — the same remote the
  # interactive `euc-share` alias in terminal.nix mounts. Backed up as its own
  # crypt-* archive in this repo (independent restore + prune from the home dir).
  cryptRemote = "euc2027-crypt:";
  # Dedicated, stable mount point for unattended backups. The alias uses a
  # disposable /tmp/crypt; we can't rely on the user having run it, so the script
  # mounts this itself, read-only, then unmounts. Excluded from the home archive.
  cryptMount = "${config.home.homeDirectory}/.borg-crypt-mnt";

  excludes = [
    "**/.Trash"
    "**/.cache"
    "**/.direnv"
    # All of ~/Library is treated as disposable app state/caches. Anchored to
    # the home dir so nested `Library` dirs elsewhere aren't matched by accident.
    # NOTE: iPhone/iPad backups under ~/Library/Application Support/MobileSync are
    # NOT captured — MobileSync is TCC-protected (needs Full Disk Access) and any
    # attempt to reach it makes borg descend into Application Support and error on
    # every protected sibling (Knowledge, com.apple.TCC, AddressBook, ...).
    "${config.home.homeDirectory}/Library"
    "**/node_modules"
    "**/target" # Rust build output
    "**/.cargo"
    "**/.rustup"
    "**/.npm"
    "**/*.qcow2"
    "**/*.iso"
    "**/venv"
    "**/.venv"
    "**/__pycache__"
    "${config.home.homeDirectory}/go/pkg" # Go module cache
    "${config.home.homeDirectory}/Applications" # nix-generated app bundles
    "${config.home.homeDirectory}/.vscode" # VS Code extensions
    "${config.home.homeDirectory}/.yarn" # yarn cache
    "${config.home.homeDirectory}/.dx" # Dioxus CLI cache
    cryptMount # unattended crypt mount point (empty when unmounted)
  ];

  excludeArgs = lib.concatMapStringsSep " " (p: "--exclude '${p}'") excludes;

  borgBackup = pkgs.writeShellApplication {
    name = "borg-backup-air";
    runtimeInputs = [
      pkgs.borgbackup
      pkgs.openssh
      pkgs.rclone
    ];
    text = ''
      export BORG_REPO="${repo}"
      export BORG_PASSCOMMAND="cat ${passphraseFile}"
      export BORG_RSH="ssh -i ${sshKey} -o StrictHostKeyChecking=accept-new"

      # Send all output to a per-run, timestamped log kept forever, while still
      # echoing to the terminal for manual runs. Colons are avoided in the
      # filename so it plays nicely with every tool.
      mkdir -p "${logDir}"
      runLog="${logDir}/borg-$(date '+%Y-%m-%dT%H-%M-%S').log"
      exec > >(tee -a "$runLog") 2>&1

      echo "=== borg-backup-air $(date '+%Y-%m-%d %H:%M:%S') ==="

      # Keep the Mac awake for the whole backup: -i no idle sleep, -m no disk
      # sleep, -s no system sleep (AC only). `-w $$` ties it to this script's
      # lifetime, so it goes away automatically when we exit. Absolute path
      # because launchd's PATH doesn't reliably include /usr/bin.
      /usr/bin/caffeinate -ims -w "$$" &

      # Freshness guard. The launchd agent also runs at load (RunAtLoad), which
      # gives us catch-up after a shutdown: macOS only replays StartCalendarInterval
      # slots missed while *asleep*, not while powered off, so a cold boot past a
      # slot would otherwise skip it. To avoid re-running on every login/rebuild,
      # skip when a backup already succeeded within minGap. The scheduled slots
      # (9/14/19) are all >=5h apart, so a real slot is never wrongly skipped.
      lastSuccessFile="${logDir}/.last-success"
      minGap=$((4 * 60 * 60))
      if [ -f "$lastSuccessFile" ]; then
        last="$(cat "$lastSuccessFile" 2>/dev/null || echo 0)"
        case "$last" in
          *[!0-9]*) last=0 ;;
        esac
        [ -n "$last" ] || last=0
        age=$(( $(date +%s) - last ))
        if [ "$age" -lt "$minGap" ]; then
          echo "Last backup succeeded $((age / 60)) min ago (< $((minGap / 3600))h); skipping."
          exit 0
        fi
      fi

      # Probe the repo. This doubles as our reachability check (it uses the same
      # SSH transport borg needs), so we can tell three cases apart:
      #   - reachable + exists   -> proceed
      #   - reachable + missing  -> first run, initialise it
      #   - unreachable          -> no network/Storage Box down; retry briefly
      # Retry a few times to ride out flaky connectivity within this slot; if
      # still unreachable, skip cleanly (exit 0) rather than fail — the next
      # scheduled run at 9/14/19 will catch everything via dedup.
      tries=3
      retryDelay=300 # seconds between attempts
      repoState=unreachable
      for i in $(seq 1 "$tries"); do
        if info_out="$(borg info 2>&1)"; then
          repoState=ok
          break
        elif printf '%s' "$info_out" \
          | grep -qiE 'does not exist|not a valid repository'; then
          repoState=missing
          break
        fi
        echo "Attempt $i/$tries: Storage Box unreachable."
        if [ "$i" -lt "$tries" ]; then
          echo "Retrying in $((retryDelay / 60)) min..."
          sleep "$retryDelay"
        fi
      done

      if [ "$repoState" = unreachable ]; then
        echo "Storage Box still unreachable after $tries attempts; skipping this run."
        exit 0
      fi

      if [ "$repoState" = missing ]; then
        echo "Repository not initialised; running borg init..."
        borg init --encryption=repokey-blake2
      fi

      rc=0
      borg create \
        --verbose --stats --show-rc \
        --compression auto,zstd \
        --exclude-caches \
        --exclude-if-present .nobackup \
        ${excludeArgs} \
        "::air-{now:%Y-%m-%dT%H:%M:%S}" \
        "${config.home.homeDirectory}" || rc=$?
      if [ "$rc" -gt 1 ]; then
        echo "borg create failed with exit code $rc" >&2
        exit "$rc"
      fi

      # --- Crypt volume (rclone remote) ---------------------------------------
      # Mount the euc2027-crypt: remote read-only to a dedicated path, back it up
      # as its own crypt-* archive, then unmount. This runs *before* prune/compact
      # on purpose: those are repo maintenance and regularly die on a Storage Box
      # SSH reset (rc 2), which under `set -e` used to abort the run and silently
      # skip the crypt archive entirely.
      echo "=== crypt volume ==="
      mkdir -p "${cryptMount}"
      cryptReady=0
      echo "Mounting ${cryptRemote} at ${cryptMount} (read-only)..."
      rclone mount "${cryptRemote}" "${cryptMount}" \
        --read-only --vfs-cache-mode minimal &
      rcloneMountPid=$!
      # Tear the mount down on any exit from here on.
      trap 'kill "$rcloneMountPid" 2>/dev/null || true' EXIT

      # Wait up to ~30s for the FUSE mount to appear in the mount table.
      for _ in $(seq 1 30); do
        if /sbin/mount | grep -qF "${cryptMount}"; then
          cryptReady=1
          break
        fi
        sleep 1
      done

      if [ "$cryptReady" = 1 ]; then
        echo "Crypt mount ready; creating archive..."
        crc=0
        borg create \
          --verbose --stats --show-rc \
          --compression auto,zstd \
          "::crypt-{now:%Y-%m-%dT%H:%M:%S}" \
          "${cryptMount}" || crc=$?
        if [ "$crc" -gt 1 ]; then
          echo "crypt borg create failed with exit code $crc" >&2
        fi
      else
        echo "Crypt mount not ready after 30s; skipping crypt backup this run." >&2
      fi

      # Unmount now instead of waiting for the EXIT trap.
      kill "$rcloneMountPid" 2>/dev/null || true
      trap - EXIT

      # --- Repo maintenance ----------------------------------------------------
      # Both archive sets are safely on the Storage Box by now. Prune/compact are
      # best-effort: the remote drops long-running SSH sessions often enough that
      # a hard failure here must not fail the run or block the success marker —
      # the next run retries and dedup makes the missed prune harmless.
      # --list echoes each archive with its kept/pruned decision. --save-space
      # trades a little memory for lower peak disk use on the repo side.
      # Each prune is scoped by --glob-archives so it never touches the other
      # archive set (borg prune matches ALL archives by default).
      prune() {
        borg prune --stats --show-rc --list --save-space \
          --glob-archives "$1" \
          --keep-hourly 24 \
          --keep-daily 7 \
          --keep-weekly 8 \
          --keep-monthly 6 \
          || echo "borg prune $1 failed with exit code $? (non-fatal)" >&2
      }
      prune 'air-*'
      prune 'crypt-*'
      borg compact || echo "borg compact failed with exit code $? (non-fatal)" >&2

      # Record success for the freshness guard above.
      date +%s > "$lastSuccessFile"

      # Dump the full archive list at the end so every run's log ends with the
      # current state of the repo, like the immich script does.
      echo "=== Current archives ==="
      borg list
    '';
  };
in
{
  home.packages = [ borgBackup ];

  sops.secrets."borg/air" = { };
  sops.secrets."borg/ssh_key" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519_borg";
    mode = "0600";
  };

  launchd.agents.borg-backup = {
    enable = true;
    config = {
      ProgramArguments = [ "${borgBackup}/bin/borg-backup-air" ];
      # Fixed clock schedule at hours I'm likely at the machine. launchd
      # coalesces a missed slot and runs once shortly after wake.
      StartCalendarInterval = [
        {
          Hour = 9;
          Minute = 0;
        }
        {
          Hour = 15;
          Minute = 0;
        }
        {
          Hour = 21;
          Minute = 0;
        }
      ];
      # Also run at load (boot/login/rebuild) so a slot missed while the Mac was
      # powered off gets caught up; the script's freshness guard prevents re-runs.
      RunAtLoad = true;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
      ProcessType = "Background";
      LowPriorityIO = true;
    };
  };
}
