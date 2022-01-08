{ pkgs, config, ... }:

{
  programs.mako = {
    enable = true;
    defaultTimeout = 0;
    borderColor = "#ffffff";
    backgroundColor = "#00000070";
    textColor = "#ffffff";
  };

  systemd.user.services.mako = {
    Service.WantedBy = "graphical-session.target";
    Service.After = "graphical-session.target";
    Service.PartOf = "graphical-session.target";

    Service.Type = "dbus";
    Service.BusName = "org.freedesktop.Notifications";
    Service.ExecStart = "${pkgs.mako}/bin/mako";
    Service.ExecReload = "${pkgs.mako}/bin/mako reload";
    Service.Restart = "on-failure";
    #restartTriggers = [ config.xdg.configFile."mako/config".source ];
  };
}
