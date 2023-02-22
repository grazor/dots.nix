{ pkgs, ... }:

let
  description = "Radarr";
  name = "radarr";
  image = "lscr.io/linuxserver/radarr:latest";

  path = "/home/cloud/media";
  configOpt =
    "-v ${path}/radarr/:/config -v ${path}/data/downloads:/downloads -v ${path}/data/movies/:/movies";
  extraOpt =
    "--pull=always -v /etc/localtime:/etc/localtime:ro -e TZ=Europe/Moscow -e PUID=1000 -e PGUID=1000 --net=host";
in {
  systemd.services.radarr = {
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

