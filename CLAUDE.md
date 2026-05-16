# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Nix flake managing two machines: `air` (an Apple Silicon Mac via nix-darwin + home-manager) and `docker` (an x86_64 NixOS homelab host). Both configurations live in `flake.nix` as `darwinConfigurations."air"` and `nixosConfigurations."docker"`.

## Build & apply commands

**`air` — full system rebuild** (required for any system-level change: `modules/workstations/**`, `brew.nix` casks, `environment.*`, macOS `defaults`, launchd):
```bash
darwin-rebuild switch --flake .#air
```

**`air` — home-manager-only rebuild** (preferred while iterating on anything under `users/bartjan/**` — sketchybar, terminal, aerospace, nvim, vscode). The `air` system closure includes a slow-compiling package, so avoid full `darwin-rebuild` for user-level changes:
```bash
$(nix build .#darwinConfigurations.air.config.home-manager.users.bartjan.home.activationPackage --no-link --print-out-paths --no-warn-dirty)/activate
```

**`docker` — NixOS rebuild** (run on the host):
```bash
nixos-rebuild switch --flake .#docker
```

**Evaluate / dry-build without applying:**
```bash
nix build .#darwinConfigurations.air.system --no-link
nix flake check
```

Note: untracked files are invisible to flake evaluation — `git add` new `.nix` files before building.

## Architecture

Three-layer import structure: hosts → modules → users.

- **`hosts/<name>/configuration.nix`** — per-machine entry point. Sets `hostPlatform`/`system`, timezone, `stateVersion`, and imports the relevant module sets.
- **`modules/workstations/`** — shared macOS/darwin config (`nix.nix`, `sops.nix`, `ssh.nix`, `users.nix`, `unconfigured_packages.nix`). `modules/workstations/air/` adds Mac-specific bits: `brew.nix` (Homebrew casks/MAS) and `mac.nix` (`system.defaults`).
- **`modules/homelabs/`** — shared NixOS config for homelab hosts; `modules/homelabs/docker/` adds Docker-specific config.
- **`users/bartjan/`** — home-manager config, wired in via `home-manager.darwinModules.home-manager` in `flake.nix`. `default.nix` imports per-program modules (aerospace, firefox, git, nvim, sketchybar, terminal, vscode, sops, protonmail-bridge).

Each directory uses a `default.nix` that only lists `imports`; actual config lives in sibling files. Add a new module by creating the file and adding it to the nearest `default.nix` imports list.

## Secrets (sops-nix)

Encrypted secrets live in a **separate private repo** (`github:BHenkemans/nix-secrets`, the `sops-repo` flake input) — not in this repo. `.sops.yaml` here only declares the age recipients (`bartjan` user key + `air` host key).

- System-level secrets: `modules/workstations/sops.nix`, decrypted via the host SSH key / `/var/lib/sops-nix/key.txt`.
- User-level secrets: `users/bartjan/sops.nix`, decrypted via `~/Library/Application Support/sops/age/keys.txt`. It also provisions SSH private keys and regenerates their `.pub` files on activation.

## sketchybar

`users/bartjan/sketchybar.nix` enables the sketchybar service and links `users/bartjan/assets/sketchybar/` (Lua config) into `~/.config/sketchybar`. The `sketchybarrc` wrapper explicitly re-exports `PATH` and `LUA_CPATH` because launchd starts the bar with a minimal environment. Items live in `assets/sketchybar/items/`.

## Conventions

- `tmp/` is git-ignored local scratch — never commit anything in it.
- Homebrew `masApps` are intentionally commented out in `brew.nix` (brittle to bootstrap); MAS apps are installed via the App Store GUI.
