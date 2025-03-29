{lib, ...}: {
  services.teamspeak3 = {
    enable = true;
    openFirewall = true;
    querySshPort = 10022;
    queryPort = 10011;
    queryHttpPort = 10080;
    fileTransferPort = 30033;
    defaultVoicePort = 9987;
    dataDir = "/home/cloud/teamspeak";
  };

  systemd.services.teamspeak3-server.serviceConfig = {
    User = lib.mkForce "cloud";
    Group = lib.mkForce "users";
  };
}
