{
  lib,
  config,
  ...
}: let
  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.teamspeak.enable = lib.mkEnableOption "teamspeak service";
  config = lib.mkIf cfg.teamspeak.enable {
    services.teamspeak3 = {
      enable = true;
      openFirewall = true;
      querySshPort = 10022;
      queryPort = 10011;
      queryHttpPort = 10080;
      fileTransferPort = 30033;
      defaultVoicePort = 9987;
      dataDir = "${user.home}/teamspeak";
    };

    systemd.services.teamspeak3-server.serviceConfig = {
      User = lib.mkForce user.name;
      Group = lib.mkForce user.group;
    };
  };
}
