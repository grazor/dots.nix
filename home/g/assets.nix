{ lib, ... }:

with lib;

let assetsPath = ./../../assets;
in {
  home.file =
    mapAttrs' (name: value: nameValuePair (".assets/${name}") ({ source = assetsPath + "/${name}"; }))
    (builtins.readDir assetsPath);
}
