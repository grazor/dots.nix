{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withHyprland = lib.mkEnableOption "with wayland";
  config = lib.mkIf cfg.withHyprland {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };
    };

    services = {
      libinput.enable = false;
      displayManager.defaultSession = "hyprland";
    };

    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      xwaylandvideobridge

      wofi
      swaybg
      wlsunset
      mako
      wl-clipboard
      slurp
      grim
    ];

    hardware.uinput.enable = true;

    environment.sessionVariables = {
      "NIXOS_OZONE_WL" = "1";
      "QT_QPA_PLATFORM" = "xcb";
      "QT_QPA_PLATFORMTHEME" = "qt5ct";
      "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
      "LIBVA_DRIVER_NAME" = "i965";

      "WLR_NO_HARDWARE_CURSORS" = "1";
    };
  };
}
