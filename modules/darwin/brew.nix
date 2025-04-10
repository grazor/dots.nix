{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.darwin;
in {
  options.grazor.darwin.withBrew = lib.mkEnableOption "with brew";
  config = lib.mkIf cfg.withBrew {
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "none";
        autoUpdate = true;
        upgrade = true;
      };
    };
  };
}
