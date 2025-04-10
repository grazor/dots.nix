{
  lib,
  config,
  pkgs,
  ...
}: let
  description = "Caddy Server";
  name = "caddy";
  image = "abiosoft/caddy";
  configOpt = "-v ${user.home}/caddy/Caddyfile:/etc/Caddyfile -v ${user.home}/caddy/certs:/root/.caddy";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";

  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.caddy.enable = lib.mkEnableOption "caddy service";
  config = lib.mkIf cfg.caddy.enable {
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
  };
}
