{ pkgs, config, ... }:

{
  programs.mako = {
    enable = true;
    defaultTimeout = 3000;
    borderColor = "#ffffff";
    backgroundColor = "#00000070";
    textColor = "#ffffff";
  };

  systemd.user.services.mako = {
    serviceConfig.ExecStart = "${pkgs.mako}/bin/mako";
    #restartTriggers = [ config.xdg.configFile."mako/config".source ];
  };
}
