{pkgs, ...}: let
  description = "Home Assistant";
  name = "hass";
  image = "homeassistant/home-assistant:stable";
  configOpt = "-v /home/cloud/hass/:/config";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --privileged --net=host";
in {
  systemd.services.hass = {
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
