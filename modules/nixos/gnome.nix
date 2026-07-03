# GNOME desktop environment.
{
  flake.modules.nixos.gnome = {pkgs, ...}: {
    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
      # The desktop is also an SSH/Steam target — never suspend while idle.
      displayManager.gdm.autoSuspend = false;
      desktopManager.gnome.enable = true;
      udev.packages = with pkgs; [gnome-settings-daemon];
    };

    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
        };
      }
    ];

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gnome

      wl-clipboard

      gnomeExtensions.appindicator
      dconf-editor
      gnome-tweaks
    ];

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
