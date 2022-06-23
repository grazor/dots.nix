{ pkgs, ... }:

let
  description = "Sonarr";
  name = "sonarr";
  image = "lscr.io/linuxserver/sonarr:latest";

  path = "/home/cloud/media";
  configOpt = "-v ${path}/sonarr/:/config -v ${path}/data/downloads/complete:/downloads -v ${path}/data/shows/:/tv";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro -e TZ=Europe/Moscow -e PUID=1000 -e PGUID=1000 --net=host";
in {
  systemd.services.sonarr = {
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

