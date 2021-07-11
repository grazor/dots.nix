{ pkgs, ... }:

{
  # services.xserver.videoDrivers = [ "nuoveau" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  boot.kernelParams = [ ];

  # boot.initrd.kernelModules = [ "nvidia" ];
  boot.kernelModules = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "i915" ];
}
