{
  lib,
  config,
  pkgs,
  ...
}: let
  description = "Zigbee to Mqtt";
  name = "zigbee2mqtt";
  image = "koenkk/zigbee2mqtt";
  configOpt = "-v ${user.home}/zigbee2mqtt:/app/data";
  extraOpt = "--pull=always --device=/dev/ttyACM0 -e TZ=Europe/Moscow -v /etc/localtime:/etc/localtime:ro -v /run/udev:/run/udev:ro --privileged --net=host";

  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.zegbee2mqtt.enable = lib.mkEnableOption "zegbee2mqtt service";
  config = lib.mkIf cfg.zegbee2mqtt.enable {
    systemd.services.zigbee2mqtt = {
      inherit description;

      wantedBy = ["multi-user.target"];
      requires = ["docker.service"];
      after = ["network.target"];

      serviceConfig = {
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.docker}/bin/docker run --name=${name} ${configOpt} ${extraOpt} ${image}";
        ExecStop = "${pkgs.docker}/bin/docker stop -t 2 ${name}";
        ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
      };
    };
  };
}
