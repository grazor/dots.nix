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
      intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
}
