{
  lib,
  config,
  ...
}: let
  name = "withProxy";
  cfg = config.grazor.linux;
in {
  options.grazor.linux.${name} = lib.mkEnableOption "act as server";
  config = lib.mkIf cfg.${name} {
    services.privoxy = {
      enable = true;
      settings = {
        listen-address = "0.0.0.0:9998";
        forward-socks5 = "/ 192.168.2.1:9999 .";
      };
    };
  };
}
