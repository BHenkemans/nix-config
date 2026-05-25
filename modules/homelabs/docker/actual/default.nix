{ config, ... }:
{
  sops.secrets."actual/openid_client_id" = { };
  sops.secrets."actual/openid_client_secret" = { };

  sops.templates."actual.env".content = ''
    ACTUAL_OPENID_CLIENT_ID=${config.sops.placeholder."actual/openid_client_id"}
    ACTUAL_OPENID_CLIENT_SECRET=${config.sops.placeholder."actual/openid_client_secret"}
  '';

  virtualisation.oci-containers.containers.actual = {
    image = "docker.io/actualbudget/actual-server:latest";
    autoStart = true;
    environment = {
      ACTUAL_LOGIN_METHOD = "openid";
      ACTUAL_ALLOWED_LOGIN_METHODS = "password,openid";
      ACTUAL_OPENID_DISCOVERY_URL = "https://auth.bartjan.tech/application/o/budget/.well-known/openid-configuration";
      ACTUAL_OPENID_SERVER_HOSTNAME = "https://budget.bartjan.tech";
      ACTUAL_OPENID_PROVIDER_NAME = "Authentik";
    };
    environmentFiles = [ config.sops.templates."actual.env".path ];
    volumes = [ "actual:/data" ];
    extraOptions = [
      "--network=proxy"
      "--security-opt=no-new-privileges:true"
    ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.actual.rule" = "Host(`budget.bartjan.tech`)";
      "traefik.http.routers.actual.tls" = "true";
      "traefik.http.services.actual.loadbalancer.server.port" = "5006";
    };
  };
}
