{
  lib,
  config,
  pkgs,
  ...
}: let
  bin = ../../../bin;
  dirname = ".bin";

  username = config.grazor.user.name;
  cfg = config.grazor.user.config;
in {
  options.grazor.user.config.withScripts = lib.mkEnableOption "with scripts";
  config = lib.mkIf cfg.withScripts {
    home-manager.users.${username} = {
      home.packages = [pkgs.lefthook];
      xdg.configFile."lefthook/general.yml".source = ../config/lefthook.general.yml;

      home.file = lib.mapAttrs' (
        name: _: lib.nameValuePair "${dirname}/${name}" {source = bin + "/${name}";}
      ) (builtins.readDir bin);
    };
  };
}
