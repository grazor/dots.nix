# Personal scripts (~/.bin).
{
  flake.modules.homeManager.scripts = {lib, ...}: let
    bin = ../../bin;
    dirname = ".bin";
  in {
    home.sessionPath = ["$HOME/${dirname}"];

    home.file = lib.mapAttrs' (
      name: _: lib.nameValuePair "${dirname}/${name}" {source = bin + "/${name}";}
    ) (builtins.readDir bin);
  };
}
