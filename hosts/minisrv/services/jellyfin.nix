{ pkgs, ... }:

let
  description = "Jellyfin";
  name = "jellyfin";
  image = "jellyfin/jellyfin";
  configOpt = "-v /home/cloud/jellyfin/config:/config -v /home/cloud/jellyfin/cache:/cache";
  extraOpt = "--mount type=bind,source=/home/cloud/media,target=/media --pull=always -v /etc/localtime:/etc/localtime:ro --net=host";
in {
  systemd.services.jellyfin = {
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

