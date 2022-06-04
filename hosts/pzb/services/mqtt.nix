{ pkgs, ... }:

let
    description = "Mqtt";
    name = "mqtt";
    image = "eclipse-mosquitto";
    configOpt = "-v /home/cloud/mosquitto/:/mosquitto";
    extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --net=host";
in
{
  systemd.services.hass = {
    Service.Description = description;
    Service.Requires = "docker.service";
    Service.After = "network.target";
    Service.WantedBy = "multi-user.target";

    Service.Restart = "always";
    Service.RestartSec = "3";
    Service.ExecStart = "${pkgs.docker} run --name=${name} ${configOpt} ${extraOpt} ${image}";
    Service.ExecStop = "${pkgs.docker} stop -t 2 ${name}";
    Service.ExecStopPost = "${pkgs.docker} rm -f ${name}";
  };
}
