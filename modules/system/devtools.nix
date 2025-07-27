{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.withDevtools = lib.mkEnableOption "with devtools installed";
  config = lib.mkIf cfg.withDevtools {
    environment.systemPackages = with pkgs; [
      python3
      shfmt
      shellcheck

      file
      git
      jq
      gnumake
      ripgrep

      k9s
      fluxcd
    ];
  };
}
