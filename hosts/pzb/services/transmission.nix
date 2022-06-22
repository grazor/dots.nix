{ pkgs, ... }:

let
  description = "Transmission";
  name = "transmission";
  image = "lscr.io/linuxserver/transmission:latest";
  configOpt = "-v /home/cloud/transmission/config/:/config";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro -e TZ=Europe/Moscow -e PUID=1000 -e PGUID=1000 -e USER=grazor -e FILE__PASSWORD=/config/password --net=host -v /home/cloud/transmission/downloads/:/downloads -v /home/cloud/transmission/watch/:/watch";
in {
  systemd.services.transmission = {
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
