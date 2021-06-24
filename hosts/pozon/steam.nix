{ config, pkgs, ... }:

{
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
      extraPackages32 = with pkgs.pkgsi686Linux;
        [ libva ] ++ lib.optionals config.services.pipewire.enable [ pipewire ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: [ pkgs.mono pkgs.libgdiplus pkgs.pipewire.lib ];
      extraLibraries = pkgs: [ pkgs.pipewire ];
    };
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}

