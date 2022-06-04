{ pkgs, ... }:

let 
    description = "Zigbee to Mqtt";
    name = "zigbee2mqtt";
    image = "koenkk/zigbee2mqtt";
    configOpt = "-v /home/cloud/zigbee2mqtt:/app/data";
    extraOpt = "--pull=always --device=/dev/ttyACM0 -e TZ=Europe/Moscow -v /etc/localtime:/etc/localtime:ro -v /run/udev:/run/udev:ro --privileged=tru --net=host";
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
