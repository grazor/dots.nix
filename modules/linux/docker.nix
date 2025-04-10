{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withDocker = lib.mkEnableOption "with docker";
  config = lib.mkIf cfg.withDocker {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
