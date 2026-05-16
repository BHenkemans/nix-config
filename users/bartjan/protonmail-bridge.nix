{ pkgs, ... }:
{
  launchd.agents.protonmail-bridge = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.protonmail-bridge}/bin/protonmail-bridge"
        "--noninteractive"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/protonmail-bridge.log";
      StandardErrorPath = "/tmp/protonmail-bridge.err.log";
    };
  };
}
