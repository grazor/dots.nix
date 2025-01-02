{ pkgs, ... }:

{
  services = {
    syncthing = {
      enable = true;
      group = "cloud";
      user = "users";
      dataDir = "/home/cloud/syncthing/data";
      configDir = "/home/cloud/syncting/config";
      #settings.gui.user = "grazor";
    };
  };
}
