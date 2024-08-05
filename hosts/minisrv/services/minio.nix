{ ... }:

{
  services.minio = {
    enable = true;

    listenAddress = ":8333";
    dataDir = [ "/home/cloud/minio/data" ];
    configDir = "/home/cloud/minio/config";

    browser = true;
    consoleAddress = ":8334";
  };
}
