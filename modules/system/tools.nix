{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.withTools = lib.mkEnableOption "install extra utilities";
  config = lib.mkIf cfg.withTools {
    environment.systemPackages = with pkgs; [
      inetutils
      netcat
      curl

      file
      tree
      unar
      unzip

      ncdu
      dua # <- aka ncdu

      ffmpeg
      gifsicle
    ];
  };
}
