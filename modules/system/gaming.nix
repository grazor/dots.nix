{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.withGaming = lib.mkEnableOption "with gaming tools installed";
  config = lib.mkIf cfg.withDevtools {
    environment.systemPackages = with pkgs; [
      teamspeak3
    ];
  };
}
