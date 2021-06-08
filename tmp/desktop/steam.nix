{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override { extraPkgs = pkgs: [ pkgs.mono pkgs.libgdiplus ]; };
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

}
