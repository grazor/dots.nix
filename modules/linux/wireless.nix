{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withWireless = lib.mkEnableOption "with wireless support";
  config = lib.mkIf cfg.withWireless {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    environment.systemPackages = [pkgs.wirelesstools];
  };
}
