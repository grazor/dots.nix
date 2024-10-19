{ config, lib, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://vw.porivaev.ru";
      signupsAllowed = false;
      rocketPort = 3011;
      websocketEnabled = true;
    };
  };

  users = {
    users.vaultwarden.name = "cloud";
    groups.vaultwarden.name = "users";
  };
}
