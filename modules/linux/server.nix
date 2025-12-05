{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.asServer = lib.mkEnableOption "act as server";
  config = lib.mkIf cfg.asServer {
    services.logind.settings.Login.HandleLidSwitch = "ignore";
    boot.kernelParams = ["consoleblank=120"];
    grazor.sshServer = lib.mkForce true;
    grazor.withAuthorizedKeys = lib.mkForce true;
  };
}
