{pkgs, ...}: let
  description = "Caddy Server";
  name = "caddy";
  image = "abiosoft/caddy";
  configOpt = "-v /home/cloud/caddy/Caddyfile:/etc/Caddyfile -v /home/cloud/caddy/certs:/root/.caddy";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";
in {
  systemd.services.caddy = {
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
