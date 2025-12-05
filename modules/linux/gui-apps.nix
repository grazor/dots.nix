{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withGuiApps = lib.mkEnableOption "with gui apps";
  config = lib.mkIf cfg.withGuiApps {
    environment.systemPackages = with pkgs; [
      librewolf-bin
      mpv
      #blender
      iwgtk
      feh
      inkscape
      #gimp
      tdesktop
      obsidian
      resources
      qbittorrent

      rose-pine-cursor
      nordzy-cursor-theme
    ];
  };
}
