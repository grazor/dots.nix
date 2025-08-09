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
      asServer = true;
      withCommon = false;
      withWireless = true;
      withUserDefaults = true;
      withUdev = true;
    };

    services = {
      zigbee2mqtt.enable = true;
    };

    withTools = true;
    withDevtools = false;
    withNvf = true;
    withAuthorizedKeys = true;
    sshServer = true;
  };
}
