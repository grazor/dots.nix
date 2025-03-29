{lib, ...}: {
  services.xray = {
    enable = true;
    settingsFile = "/home/cloud/xray/config.json";
  };

  systemd.services.xray.serviceConfig = {
    User = lib.mkForce "cloud";
    Group = lib.mkForce "users";
  };
}
