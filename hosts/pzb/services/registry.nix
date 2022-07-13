{ pkgs, ... }:

let
  description = "Docker registry";
  name = "registry";
  image = "registry:2";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --net=host";
in {
  systemd.services.registry = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.docker}/bin/docker run --name=${name} ${configOpt} ${extraOpt} ${image}";
      ExecStop = "${pkgs.docker}/bin/docker stop -t 2 ${name}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
    };
  };
}
