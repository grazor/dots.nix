{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
  opt = "with3DPrint";
in {
  options.grazor.${opt} = lib.mkEnableOption "with 3d printing tools";
  config = lib.mkIf cfg.${opt} {
    environment.systemPackages = with pkgs; [
      orca-slicer
    ];
  };
}
