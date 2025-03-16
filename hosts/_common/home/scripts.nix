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
    name: _: lib.nameValuePair "${dirname}/${name}" {source = bin + "/${name}";}
  ) (builtins.readDir bin);
}
