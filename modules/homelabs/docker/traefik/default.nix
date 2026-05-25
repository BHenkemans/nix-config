{ config, pkgs, ... }:
{
  sops.secrets."traefik/cf" = { };
  sops.secrets."traefik/dashboard" = { };

  virtualisation.oci-containers.backend = "podman";

  systemd.tmpfiles.rules = [
    "d /var/lib/traefik 0750 root root -"
    "f /var/lib/traefik/acme.json 0600 root root -"
  ];

  # Create the external proxy network before the container starts
  systemd.services.podman-traefik-network = {
    description = "Create traefik proxy network";
    after = [ "network.target" ];
    before = [ "podman-traefik.service" ];
    requiredBy = [ "podman-traefik.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network inspect proxy >/dev/null 2>&1 || \
        ${pkgs.podman}/bin/podman network create proxy
    '';
  };

  environment.etc."traefik/traefik.yml".source = ./assets/traefik.yml;
  environment.etc."traefik/config.yml".source = ./assets/traefik-config.yml;

  virtualisation.oci-containers.containers.traefik = {
    image = "traefik:latest";
    autoStart = true;
    environment = {
      CF_DNS_API_TOKEN_FILE = "/run/secrets/cf_api_token";
    };
    ports = [
      "80:80"
      "443:443"
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
      "/etc/traefik/traefik.yml:/traefik.yml:ro"
      "/var/lib/traefik/acme.json:/acme.json"
      "/etc/traefik/config.yml:/config.yml:ro"
      "${config.sops.secrets."traefik/cf".path}:/run/secrets/cf_api_token:ro"
      "${config.sops.secrets."traefik/dashboard".path}:/run/secrets/dashboard_credentials:ro"
    ];
    extraOptions = [
      "--network=proxy"
      "--security-opt=no-new-privileges:true"
    ];
    labels = {
      "traefik.enable" = "true";

      # Dashboard router (HTTP, redirects to HTTPS)
      "traefik.http.routers.traefik.entrypoints" = "http";
      "traefik.http.routers.traefik.rule" = "Host(`traefik.bartjan.tech`)";
      "traefik.http.routers.traefik.middlewares" = "traefik-https-redirect";

      # Middlewares
      "traefik.http.middlewares.traefik-auth.basicauth.usersfile" = "/run/secrets/dashboard_credentials";
      "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme" = "https";
      "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto" = "https";

      # Dashboard router (HTTPS)
      "traefik.http.routers.traefik-secure.entrypoints" = "https";
      "traefik.http.routers.traefik-secure.rule" = "Host(`traefik.bartjan.tech`)";
      "traefik.http.routers.traefik-secure.middlewares" = "traefik-auth";
      "traefik.http.routers.traefik-secure.tls" = "true";
      "traefik.http.routers.traefik-secure.tls.certresolver" = "cloudflare";
      "traefik.http.routers.traefik-secure.tls.domains[0].main" = "local.henkemans.be";
      "traefik.http.routers.traefik-secure.tls.domains[0].sans" = "*.local.henkemans.be";
      "traefik.http.routers.traefik-secure.tls.domains[1].main" = "bartjan.tech";
      "traefik.http.routers.traefik-secure.tls.domains[1].sans" = "*.bartjan.tech";
      "traefik.http.routers.traefik-secure.service" = "api@internal";
    };
  };
}
