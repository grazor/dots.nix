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

  services.xserver.windowManager.i3 = { enable = false; };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  /*
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  xdg.portal.gtkUsePortal = true;

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway"; # https://github.com/emersion/xdg-desktop-portal-wlr/issues/20
    XDG_SESSION_TYPE = "wayland"; # https://github.com/emersion/xdg-desktop-portal-wlr/pull/11
  };
  */
}
