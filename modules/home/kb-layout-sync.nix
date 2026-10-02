# Keep the Corne's layer in step with the macOS input source (see
# bin/kb-layout-sync). Runs as a login agent in the GUI session.
{
  flake.modules.homeManager.kb-layout-sync = {config, ...}: {
    launchd.agents.kb-layout-sync = {
      enable = true;
      config = {
        ProgramArguments = ["${../../bin/kb-layout-sync}"];
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 30;
        LimitLoadToSessionType = "Aqua";
        ProcessType = "Interactive";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/kb-layout-sync.log";
      };
    };
  };
}
