_ : {
  homebrew = {
    enable = true;
    casks = [
      "microsoft-teams"
      "zotero"
      "sioyek"
      "macfuse"
      "mattermost"
      "gnucash"
    ];
    # masApps = {
    #   "WhatsApp" = 310633997;
    #   "EduVPN" = 1317704208;
    #   "Word" = 462054704;
    #   "PowerPoint" = 462062816;
    #   "Outlook" = 985367838;
    #   "Excel" = 462058435;
    #   "Windows App" = 1295203466; 
    # };
    onActivation = {
      # cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
