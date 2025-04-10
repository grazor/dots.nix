{
  lib,
  config,
  ...
}: let
  inherit (config.grazor) user;
  cfg = config.grazor.services;
in {
  options.grazor.services.minio.enable = lib.mkEnableOption "minio service";
  config = lib.mkIf cfg.minio.enable {
    services.minio = {
      enable = true;

      listenAddress = "0.0.0.0:8333";
      dataDir = ["${user.home}/minio/data"];

      browser = true;
      consoleAddress = "0.0.0.0:8334";
    };

    systemd.services.minio.serviceConfig = let
      cfg = config.services.minio;
    in {
      ExecStart = lib.mkForce "${cfg.package}/bin/minio server --json --address ${cfg.listenAddress} --console-address ${cfg.consoleAddress} ${toString cfg.dataDir}";
      User = lib.mkForce user.name;
      Group = lib.mkForce user.group;
      EnvironmentFile = lib.mkForce "${user.home}/minio/env";
    };
  };
}
