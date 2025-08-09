{
  lib,
  config,
  pkgs,
  ...
}: let
  home = config.grazor.user.home;
  cfg = config.grazor.linux;
  opt = "zigbee2mqtt"
in {
  options.grazor.linux.${opt}.enable = lib.mkEnableOption "with z2m";
  config = lib.mkIf cfg.${opt}.enable {
    services.zigbee2mqtt = {
      enable = true;
      dataDir = home + "/" + "zigbee2mqtt";
      settings = {
        permit_join = false;
        frontend.enabled = true;
        homeassistant.enabled = true;

        serial.port = "/dev/ttyACM0";
        serial.adapter = "zstack";
      };
    };
  };
}
