{ config, pkgs, ... }:

{
  # kernel options
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.zfs.extraPools = [ "pvs" ];
  services.zfs.autoScrub.enable = true;

  environment.systemPackages = [ pkgs.zfs ];

  networking.hostId = "89ffcbd0";
}
