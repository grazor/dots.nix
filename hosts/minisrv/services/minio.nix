{
  config,
  lib,
  ...
}: {
  services.minio = {
    enable = true;

    listenAddress = "0.0.0.0:8333";
    dataDir = ["/home/cloud/minio/data"];

    browser = true;
    consoleAddress = "0.0.0.0:8334";
  };

  systemd.services.minio.serviceConfig = let
    cfg = config.services.minio;
  in {
    ExecStart = lib.mkForce "${cfg.package}/bin/minio server --json --address ${cfg.listenAddress} --console-address ${cfg.consoleAddress} ${toString cfg.dataDir}";
    User = lib.mkForce "cloud";
    Group = lib.mkForce "users";
    EnvironmentFile = lib.mkForce "/home/cloud/minio/env";
  };
}
