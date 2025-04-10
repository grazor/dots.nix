{
  lib,
  config,
  ...
}: let
  inherit (config.grazor.user.config) withTmux;
  cfg = config.grazor.darwin;
in {
  options.grazor.darwin.withSudo = lib.mkEnableOption "with sudo pam";
  config = lib.mkIf cfg.withSudo {
    security.pam.services.sudo_local.touchIdAuth = true;
    security.pam.services.sudo_local.reattach = withTmux;
  };
}
