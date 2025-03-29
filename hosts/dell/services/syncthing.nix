_: {
  services = {
    syncthing = {
      enable = true;
      group = "users";
      user = "cloud";
      dataDir = "/home/cloud/syncthing/data";
      configDir = "/home/cloud/syncting/config";
      guiAddress = "0.0.0.0:8384";
    };
  };
}
