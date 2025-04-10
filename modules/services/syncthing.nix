{
  lib,
  config,
  ...
}: let
  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.syncthing.enable = lib.mkEnableOption "syncthing service";
  config = lib.mkIf cfg.syncthing.enable {
    services = {
      syncthing = {
        enable = true;
        group = user.name;
        user = user.group;
        dataDir = "${user.home}/syncthing/data";
        configDir = "${user.home}/syncting/config";
        guiAddress = "0.0.0.0:8384";
      };
    };
  };
}
