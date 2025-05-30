{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
  opt = "withGaming";
in {
  options.grazor.${opt} = lib.mkEnableOption "with gaming tools installed";
  config = lib.mkIf cfg.${opt} {
    environment.systemPackages = with pkgs; [
      teamspeak3
    ];
  };
}
