{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withGnome = lib.mkEnableOption "with gnome de";
  config = lib.mkIf cfg.withGnome {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome

      wlsunset
      mako
      wl-clipboard
      slurp
      grim

      # extensions
      gnomeExtensions.appindicator # tray
    ];

    # tray
    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages = with pkgs; [
      atomix
      #cheese # webcam tool
      epiphany # web browser
      #evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      #gnome-photos
      #gnome-terminal
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ];
  };
}
