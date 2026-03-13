{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
      };
      DisablePocket = true;
      ExtensionSettings = {
        #Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          "installation_mode" = "force_installed";
          "install_url" ="https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack" = {
          "installation_mode" = "force_installed";
          "install_url" ="https://addons.mozilla.org/firefox/downloads/latest/grammarly-1/latest.xpi";
        };
        #"@testpilot-containers" = {
        #  "installation_mode" = "force_installed";
        #  "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
        #};
      };
    };
    
    # Define profiles
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      
      # about:config settings go here
      settings = {
        "browser.startup.homepage" = "https://google.com";
        "browser.search.defaultenginename" = "Google";
        "browser.search.order.1" = "Google";
        
        # Privacy & Unbloating
        "privacy.trackingprotection.enabled" = true;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.unified" = false;
        
        # UI Tweaks
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # Compact density
        "browser.tabs.firefox-view" = false; # Removes the "Firefox View" tab
      };
    };
  };
}
