{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.darwin;
in {
  options.grazor.darwin.withCommon = lib.mkEnableOption "with common defaults";
  config = lib.mkIf cfg.withCommon {
    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "right";
      };
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "clmv";
      screencapture.location = "~/Pictures/screenshots";
    };
  };
}
