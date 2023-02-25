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
      minSpeed = "0.8";
      additionalOptions =
        "	Option \"VertScrollDelta\" \"-27\"\n	Option \"HorizScrollDelta\" \"-27\"\n";
    };
  };

  services.xserver.windowManager.i3 = { enable = true; };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # hyprland
  #programs.hyprland = {
  #enable = false;
  #
  #xwayland = {
  #enable = true;
  #hidpi = true;
  #};
  #
  #nvidiaPatches = false;
  #};

  environment.sessionVariables = rec {
    "QT_QPA_PLATFORM" = "xcb";
    "QT_QPA_PLATFORMTHEME" = "qt5ct";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    mpv
    iwgtk
    libreoffice
    feh
    inkscape
    gimp
    tdesktop
    zoom-us
    obsidian
  ];
}

