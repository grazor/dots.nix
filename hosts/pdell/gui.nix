{ pkgs, ... }:

{
  services.xserver.videoDrivers = [ "intel" ];

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

	#"QT_QPA_PLATFORM" = "wayland";
  environment.sessionVariables = rec {
	"QT_QPA_PLATFORM" = "xcb";
	"QT_QPA_PLATFORMTHEME" = "qt5ct";
	"QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
  };

  environment.systemPackages = with pkgs; [ google-chrome mpv ];
}
