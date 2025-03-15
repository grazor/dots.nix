{
  lib,
  pkgs,
  ...
}: let
  bin = ../../../bin;
  dirname = ".bin";
in {
  home.packages = [pkgs.lefthook];
  xdg.configFile."lefthook/general.yml".source = ../config/lefthook.general.yml;

  home.file = lib.mapAttrs' (
    name: src: lib.nameValuePair "${dirname}/${name}" {source = "${src}/${name}";}
  ) (builtins.readDir bin);
}
