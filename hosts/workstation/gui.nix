{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
      defaultSession = "hyprland";
    };
    libinput.enable = false;
  };

  hardware.uinput.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
    driSupport = true;
    driSupport32Bit = true;
  };

  environment.sessionVariables = rec {
    "NIXOS_OZONE_WL" = "1";
    "QT_QPA_PLATFORM" = "xcb";
    "QT_QPA_PLATFORMTHEME" = "qt5ct";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "LIBVA_DRIVER_NAME" = "i965";
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
