{
  lib,
  config,
  pkgs,
  ...
}: let
  description = "Influxdb";
  name = "influx";
  image = "influxdb";
  configOpt = "-v ${user.home}/influx/config:/etc/influxdb2 -v ${user.home}/influx/data:/var/lib/influxdb2";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";

  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.influxdb.enable = lib.mkEnableOption "influxdb service";
  config = lib.mkIf cfg.influxdb.enable {
    systemd.services.influx = {
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
