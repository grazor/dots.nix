{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.withFonts = lib.mkEnableOption "with fonts";
  config = lib.mkIf cfg.withFonts {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.hack
        nerd-fonts.sauce-code-pro
      ];
    };
  };
}
