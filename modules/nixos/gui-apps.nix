# Graphical applications (the Zen browser is its own `zen` aspect).
{
  flake.modules.nixos.gui-apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      mpv
      iwgtk
      feh
      inkscape
      telegram-desktop
      obsidian
      resources
      qbittorrent

      rose-pine-cursor
      nordzy-cursor-theme
    ];
  };
}
