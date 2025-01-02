{ pkgs, ... }:

{
  services = {
    syncthing = {
      enable = true;
      group = "users";
      user = "g";
      dataDir = "/home/g/.syncthing/data";
      configDir = "/home/g/.syncting/config";
    };
  };
}
