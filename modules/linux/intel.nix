{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withIntel = lib.mkEnableOption "with intel graphics";
  config = lib.mkIf cfg.withNvidia {
    services.xserver.videoDrivers = ["modesetting"];

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
