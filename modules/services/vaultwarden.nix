{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.services;
in {
  options.grazor.services.vaultwarden.enable = lib.mkEnableOption "vaultwarden service";
  options.grazor.services.vaultwarden.domain = lib.mkOption {
    type = lib.types.str;
    default = "";
  };

  config = lib.mkIf cfg.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        inherit (cfg.vaultwarden) domain;
        signupsAllowed = false;
        rocketPort = 3011;
        websocketEnabled = true;
      };
    };
  };
}
