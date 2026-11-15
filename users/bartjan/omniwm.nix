_: {
  # OmniWM itself comes from the Homebrew cask (modules/workstations/air/brew.nix):
  # a stable /Applications path keeps its Accessibility/Screen Recording grants
  # across upgrades, which a changing /nix/store path would not.
  #
  # settings.toml is not managed here yet. OmniWM validates it strictly (one
  # missing key rejects the whole file), so let it generate the canonical file
  # on first launch, tune it via the Settings window, then copy
  # ~/.config/omniwm/settings.toml into ./assets/omniwm/ and link it with
  # xdg.configFile (force = true, since OmniWM replaces the symlink on save).
  launchd.agents.omniwm = {
    enable = true;
    config = {
      Program = "/Applications/OmniWM.app/Contents/MacOS/OmniWM";
      RunAtLoad = true;
      # Restart after a crash, but let "Quit OmniWM" actually quit.
      KeepAlive.SuccessfulExit = false;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/omniwm.log";
      StandardErrorPath = "/tmp/omniwm.err.log";
    };
  };
}
