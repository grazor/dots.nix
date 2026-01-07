{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.production;
in {
  options.grazor.linux.withNvidia = lib.mkEnableOption "with nvidia";
  config = lib.mkIf cfg.withNvidia {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
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
