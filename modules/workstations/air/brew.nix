_ : {
  homebrew = {
    enable = true;
    casks = [
      "microsoft-teams"
      # zotero, macfuse: temporarily removed — patched brew in nix-homebrew
      # 5.1.7 chokes parsing their cask metadata. Re-add once nix-homebrew
      # bumps the brew version.
    ];
    # mas-cli requires apps to already exist in your Apple ID purchase history,
    # which is brittle to bootstrap. Install MAS apps via the App Store GUI.
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
