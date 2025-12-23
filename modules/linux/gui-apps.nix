{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withGuiApps = lib.mkEnableOption "with gui apps";
  config = lib.mkIf cfg.withGuiApps {
    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      librewolf-bin
      mpv
      #blender
      iwgtk
      feh
      inkscape
      #gimp
      telegram-desktop
      obsidian
      resources
      qbittorrent

      rose-pine-cursor
      nordzy-cursor-theme
    ];
  };
}
