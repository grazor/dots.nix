# Personal scripts (~/.bin) + lefthook.
{
  flake.modules.homeManager.scripts = {
    pkgs,
    lib,
    ...
  }: let
    bin = ../../bin;
    dirname = ".bin";
  in {
    home.packages = [pkgs.lefthook];
    home.sessionPath = ["$HOME/${dirname}"];
    xdg.configFile."lefthook/general.yml".source = ./raw/lefthook.general.yml;

    home.file =
      lib.mapAttrs' (
        name: _: lib.nameValuePair "${dirname}/${name}" {source = bin + "/${name}";}
      ) (builtins.readDir bin);
  };
}
