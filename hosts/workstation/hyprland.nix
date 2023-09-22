{ pkgs, ... }:
let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  hyprland-flake = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;
in {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = false;
    package = hyprland-flake.packages.${pkgs.system}.hyprland;
  };
}
