{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
in {
  options.grazor.linux.withNvidia = lib.mkEnableOption "with nvidia";
  config = lib.mkIf cfg.withNvidia {
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
  };
}
