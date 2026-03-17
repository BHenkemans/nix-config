{ pkgs, ... } : {
  environment.systemPackages = with pkgs; [
    openssh
    libfido2
  ];
  services.openssh = {
    enable = true;
    # settings.PasswordAuthentication = false;
  };
}
