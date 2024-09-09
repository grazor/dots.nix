{ pkgs, ... }:

let
  description = "Pi-hole";
  name = "pihole";
  image = "pihole/pihole";
  configOpt = "-v /home/cloud/pihole/config:/etc/pihole -v /home/cloud/pihole/dnsmasq.d:/etc/dnsmasq.d";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro -p 53:53/tcp -p 53:53/udp -p 8400:80/tcp --privileged -e DNSMASQ_USER=root -e PIHOLE_UID=1000 -e PIHOLE_GID=100";
in
{
  systemd.services.pihole = {
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
