{ config, lib, ... }:

{
  services.xray = {
    enable = true;
    settingsFile = "/home/cloud/xray/config.json";

  };

  systemd.services.xray.serviceConfig = let cfg = config.services.xray; in {
    User = lib.mkForce "cloud";
    Group = lib.mkForce "users";
  };
}
