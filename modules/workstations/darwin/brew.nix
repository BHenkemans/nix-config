_: {
  homebrew = {
    enable = true;
    brews = [
      "python@3.12"
      "uv"
      "can1357/tap/omp"
      "siderolabs/tap/talosctl"
    ];

    # macOS GUI applications (Casks)
    casks = [
      "google-chrome"
      "macfuse"
      "mattermost"
      "microsoft-teams"
      "zotero"
      "claude"
      "nextcloud"
      "gnucash"
      "vorssaint"
      "slack"
      "claude-code"
      "radix"
      "keepassxc"
    ];

    # masApps = {
    #   "WhatsApp"    = 310633997;
    #   "EduVPN"      = 1317704208;
    #   "Word"        = 462054704;
    #   "PowerPoint"  = 462062816;
    #   "Outlook"     = 985367838;
    #   "Excel"       = 462058435;
    #   "Windows App" = 1295203466;
    # };
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
