{ pkgs, ... }:

let
  description = "Chat messages to fleeting notes";
  name = "fleeting-chat";
in
{
  environment.systemPackages = with pkgs; [ fleeting-chat ];

  systemd.services.fleeting-chat = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "exec";
      User = "cloud";
      Group = "users";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.fleeting-chat}/bin/fleeting-chat";
      WorkingDirectory = "/home/cloud/fleeting-chat";
    };
  };
}
