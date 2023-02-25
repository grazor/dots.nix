{ pkgs, lib, config, ... }:

with lib;

{
  home.packages = with pkgs; [
    wofi
    swaybg
    wlsunset
    mako # notification daemon
    wl-clipboard # clipboard tool
    clipman # clipboard manager
    slurp # screen area selection
    grim # image grabber
  ];

  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
}
