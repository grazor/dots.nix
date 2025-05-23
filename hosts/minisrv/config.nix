{pkgs, ...}: {
  grazor = {
    user = rec {
      uid = 1000;
      name = "cloud";
      gid = 100;
      group = "users";
      home = "/home/${name}";
      shell = pkgs.fish;

      config = {
        withGit = true;
        withTmux = true;
        shellInitTmux = false;
        withFish = true;
        withScripts = true;
      };
    };

    linux = {
      withCommon = true;
      withWireless = true;
      withNvidia = true;
      withDocker = true;
      withUserDefaults = true;
      withUdev = true;
      withPipewire = true;
      asServer = true;
    };

    services = {
      hass.enable = true;
      mqtt.enable = true;
      zigbee2mqtt.enable = true;
      caddy.enable = true;
      influxdb.enable = true;
      grafana.enable = true;
      minio.enable = true;
      xray.enable = true;
      teamspeak.enable = true;
      vaultwarden.enable = true;
      syncthing.enable = true;

      fleeting-chat.enable = true;
    };

    withTools = true;
    withDevtools = true;
    withNvf = true;
    withFonts = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
