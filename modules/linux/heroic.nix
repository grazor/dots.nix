{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withHeroic = lib.mkEnableOption "with heroic";
  config = lib.mkIf cfg.withHeroic {
    environment.systemPackages = with pkgs; [
      heroic
      gogdl
    ];
  };
}
