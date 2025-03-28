{pkgs, ...}: let
  description = "Grafana Dashboard";
  name = "grafana";
  image = "grafana/grafana-oss";
  configOpt = "-v /home/cloud/grafana:/var/lib/grafana";
  extraOpt = "--user 1000 --pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";
in {
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
}
