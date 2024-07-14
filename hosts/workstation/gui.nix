{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    synaptics = {
      enable = true;
      vertTwoFingerScroll = true;
      vertEdgeScroll = false;
      minSpeed = "0.8";
      additionalOptions = "	Option \"VertScrollDelta\" \"-27\"\n	Option \"HorizScrollDelta\" \"-27\"\n";
    };

    windowManager.i3 = {
      enable = true;
    };
  };

  services = {
    libinput.enable = false;
    displayManager.defaultSession = "hyprland";
  };

  hardware.uinput.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    "NIXOS_OZONE_WL" = "1";
    "QT_QPA_PLATFORM" = "xcb";
    "QT_QPA_PLATFORMTHEME" = "qt5ct";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "LIBVA_DRIVER_NAME" = "i965";

    "WLR_NO_HARDWARE_CURSORS" = "1";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    mpv
    iwgtk
    feh
    inkscape
    gimp
    tdesktop
    obsidian

    wayvnc
    sunshine
  ];
}
