{ config, pkgs, ... }:
let
  # Rootful podman stores named volumes under this path.
  dataDir = "/var/lib/containers/storage/volumes/vaultwarden/_data";
in
{
  sops.secrets."vaultwarden/admin_token" = { };
  sops.secrets."vaultwarden/sso_client_secret" = { };
  sops.secrets."vaultwarden/smtp_password" = { };
  sops.secrets."vaultwarden/tunnel_token" = { };

  sops.templates."vaultwarden.env".content = ''
    ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin_token"}
    SSO_CLIENT_SECRET=${config.sops.placeholder."vaultwarden/sso_client_secret"}
    SMTP_PASSWORD=${config.sops.placeholder."vaultwarden/smtp_password"}
  '';

  sops.templates."vaultwarden-tunnel.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder."vaultwarden/tunnel_token"}
  '';

  systemd.services.podman-vaultwarden-network = {
    description = "Create vaultwarden podman network";
    after = [ "network.target" ];
    before = [
      "podman-vaultwarden.service"
      "podman-vaultwarden-tunnel.service"
    ];
    requiredBy = [
      "podman-vaultwarden.service"
      "podman-vaultwarden-tunnel.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network inspect vaultwarden >/dev/null 2>&1 || \
        ${pkgs.podman}/bin/podman network create vaultwarden
    '';
  };

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:latest";
    pull = "newer";
    autoStart = true;
    environment = {
      DOMAIN = "https://vault.henkemans.be";
      SIGNUPS_ALLOWED = "false";

      SSO_ENABLED = "true";
      SSO_AUTHORITY = "https://auth.bartjan.tech/application/o/vaultwarden/";
      SSO_CLIENT_ID = "BUan9uWFSA4AA2aZwjbzY9UWVRzQgwlLXNAM35oV";
      SSO_SCOPES = "openid email profile offline_access";
      SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION = "true";
      SSO_CLIENT_CACHE_EXPIRATION = "0";
      SSO_ONLY = "false";
      SSO_SIGNUPS_MATCH_EMAIL = "true";

      SMTP_HOST = "mail.henkemans.eu";
      SMTP_FROM = "svc_vaultwarden@bartjan.tech";
      SMTP_PORT = "465";
      SMTP_SECURITY = "force_tls";
      SMTP_USERNAME = "svc_vaultwarden@bartjan.tech";
    };
    environmentFiles = [ config.sops.templates."vaultwarden.env".path ];
    volumes = [ "vaultwarden:/data" ];
    extraOptions = [ "--network=vaultwarden" ];
  };

  virtualisation.oci-containers.containers.vaultwarden-tunnel = {
    image = "cloudflare/cloudflared:latest";
    pull = "newer";
    autoStart = true;
    cmd = [
      "tunnel"
      "run"
    ];
    environmentFiles = [ config.sops.templates."vaultwarden-tunnel.env".path ];
    extraOptions = [ "--network=vaultwarden" ];
    dependsOn = [ "vaultwarden" ];
  };

  # Borg backup to a dedicated Storage Box sub-account. The live SQLite DB is
  # excluded and snapshotted consistently into the staging dir instead.
  # homelab.backups.vaultwarden = {
  #   repo = "ssh://u123456-sub1@u123456.your-storagebox.de:23/./backup";
  #   paths = [ dataDir ];
  #   exclude = [
  #     "${dataDir}/db.sqlite3"
  #     "${dataDir}/db.sqlite3-wal"
  #     "${dataDir}/db.sqlite3-shm"
  #     "${dataDir}/icon_cache"
  #     "${dataDir}/tmp"
  #   ];
  #   preHook = ''
  #     if [ -f ${dataDir}/db.sqlite3 ]; then
  #       ${pkgs.sqlite}/bin/sqlite3 ${dataDir}/db.sqlite3 \
  #         ".backup '${config.homelab.backups.vaultwarden.stagingDir}/db.sqlite3'"
  #     fi
  #   '';
  # };
}
