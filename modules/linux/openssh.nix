{
  lib,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  config = lib.mkIf cfg.sshServer {
    openssh.settings.PasswordAuthentication = false;
  };
}
