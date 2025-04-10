{
  lib,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  config = lib.mkIf cfg.sshServer {
    services.openssh.settings.PasswordAuthentication = false;
  };
}
