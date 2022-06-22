{ pkgs, ... }:

let
  description = "Plex";
  name = "plex";
  image = "lscr.io/linuxserver/plex:latest";

  path = "/home/cloud/plex";
  radarrPath = "/home/cloud/radarr";
  configOpt = "-v ${path}/config/:/config -v ${radarrPath}/movies/:/movies";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro -e TZ=Europe/Moscow -e PUID=1000 -e PGUID=1000 -e VERSION=docker --net=host --device=/dev/dri:/dev/dri";
in {
  systemd.services.plex = {
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


