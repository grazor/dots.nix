{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    displayManager.defaultSession = "none+i3";

    windowManager.i3.enable = true;

    environment.systemPackages = with pkgs; [ google-chrome mpv ];
  };
}
