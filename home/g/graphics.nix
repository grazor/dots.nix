{ lib, ... }:

with lib;

let graphicsPath = ./../../graphics;
in {
  home.file =
    mapAttrs' (name: value: nameValuePair (".graphics/${name}") ({ source = graphicsPath + "/${name}"; }))
    (builtins.readDir graphicsPath);
}
