{config, ...}: let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
in {
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = nvidiaPackage;
  };
}
