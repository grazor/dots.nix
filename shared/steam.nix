{ config, pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
      extraPackages32 =
        with pkgs.pkgsi686Linux;
        [ libva ] ++ lib.optionals config.services.pipewire.enable [ pipewire ];
    };
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}
