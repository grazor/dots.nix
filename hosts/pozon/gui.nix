{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    displayManager.defaultSession = "sway";

    synaptics = {
      enable = true;
      vertTwoFingerScroll = true;
      vertEdgeScroll = false;
    };
  };

  services.xserver.windowManager.i3 = {
    enable = false;
    #extraPackages = with pkgs; [ i3blocks i3lock i3status rofi ];
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  #xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  #xdg.portal.gtkUsePortal = true;
}
