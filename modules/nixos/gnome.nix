# GNOME desktop environment.
{
  flake.modules.nixos.gnome = {pkgs, ...}: {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome

      wlsunset
      mako
      wl-clipboard
      slurp
      grim

      gnomeExtensions.appindicator
      dconf-editor
      gnome-tweaks
    ];

    services.udev.packages = with pkgs; [gnome-settings-daemon];

    environment.gnome.excludePackages = with pkgs; [
      atomix
      epiphany
      geary
      gedit
      gnome-characters
      gnome-music
      gnome-tour
      hitori
      iagno
      tali
      totem
    ];
  };
}
