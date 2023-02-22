{ pkgs, ... }:

let
  description = "Jackett";
  name = "jackett";
  image = "lscr.io/linuxserver/jackett:latest";

  path = "/home/cloud/media";
  configOpt = "-v ${path}/jackett/:/config -v ${path}/data/downloads:/downloads";
  extraOpt =
    "--pull=always -v /etc/localtime:/etc/localtime:ro -e TZ=Europe/Moscow -e PUID=1000 -e PGUID=1000 --net=host";
in {
  systemd.services.jackett = {
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

