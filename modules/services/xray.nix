{
  lib,
  config,
  ...
}: let
  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.xray.enable = lib.mkEnableOption "xray service";
  config = lib.mkIf cfg.xray.enable {
    services.xray = {
      enable = true;
      settingsFile = "${user.home}/xray/config.json";
    };

    systemd.services.xray.serviceConfig = {
      User = lib.mkForce user.name;
      Group = lib.mkForce user.group;
    };
  };
}
