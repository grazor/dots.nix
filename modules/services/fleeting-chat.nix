{
  lib,
  config,
  pkgs,
  ...
}: let
  description = "Chat messages to fleeting notes";

  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.fleeting-chat.enable = lib.mkEnableOption "fleeting-chat service";
  config = lib.mkIf cfg.fleeting-chat.enable {
    environment.systemPackages = with pkgs; [fleeting-chat];

    systemd.services.fleeting-chat = {
      inherit description;

      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        Type = "exec";
        User = user.name;
        Group = user.group;
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.fleeting-chat}/bin/fleeting-chat";
        WorkingDirectory = "${user.home}/fleeting-chat";
      };
    };
  };
}
