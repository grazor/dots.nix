{ config, pkgs, ... }:

{
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-g1 ];
    };
  };

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

