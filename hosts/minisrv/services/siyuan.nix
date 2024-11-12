{ pkgs, ... }:

let
  description = "siyuan notetaking";
  name = "siyuan";
  image = "b3log/siyuan";
  configOpt = "-v /home/cloud/siyuan/notes:/notes";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro -p 6806:6806 -e PUID=1000 -e PGID=100";
  appOpt = ''--workspace=/notes --accessAuthCode=''${SIYUAN_ACCESS_CODE}'';
in
{
  systemd.services.siyuan = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.docker}/bin/docker run --name=${name} ${configOpt} ${extraOpt} ${image} ${appOpt}";
      ExecStop = "${pkgs.docker}/bin/docker stop -t 2 ${name}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
      EnvironmentFile = "/home/cloud/siyuan/env";
    };
  };
}
