{
  lib,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.sshServer = lib.mkEnableOption "with ssh server";
  config = lib.mkIf cfg.sshServer {
    services.openssh.enable = true;
  };
}
