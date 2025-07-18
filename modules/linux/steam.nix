{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withSteam = lib.mkEnableOption "with steam";
  config = lib.mkIf cfg.withSteam {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
