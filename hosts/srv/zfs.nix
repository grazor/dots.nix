{ config, ... }"

{
  # kernel options
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];

  boot.kernelParams = [ "nohibernate" ];


  #boot.zfs.extraPools = [ "zpool_name" ];
  #services.zfs.autoScrub.enable = true;
}
