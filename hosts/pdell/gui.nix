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

  services.xserver.windowManager.i3 = { enable = true; };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [ google-chrome mpv ];
}
