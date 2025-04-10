{
  lib,
  config,
  pkgs,
  ...
}: let
  description = "Grafana Dashboard";
  name = "grafana";
  image = "grafana/grafana-oss";
  configOpt = "-v ${user.home}/grafana:/var/lib/grafana";
  extraOpt = "--user ${user.uid} --pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";

  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.grafana.enable = lib.mkEnableOption "grafana service";
  config = lib.mkIf cfg.grafana.enable {
    systemd.services.grafana = {
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
