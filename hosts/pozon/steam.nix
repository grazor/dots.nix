{ config, pkgs, ... }:

{
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: [ pkgs.mono pkgs.libgdiplus ];
      extraLibraries = pkgs: [ pkgs.pipewire ];
    };
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}

