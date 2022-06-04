{ pkgs, ... }:

let
    description = "Home Assistant";
    name = "home-assistant";
    image = "homeassistant/generic-x86-64-homeassistant";
    configOpt = "-v /home/cloud/hass/:/config";
    extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";
in
{
  systemd.services.hass = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.docker} run --name=${name} ${configOpt} ${extraOpt} ${image}";
      ExecStop = "${pkgs.docker} stop -t 2 ${name}";
      ExecStopPost = "${pkgs.docker} rm -f ${name}";
    };
  };
}
