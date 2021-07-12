{ pkgs, ... }:

{
  home.packages = with pkgs; [ tmux ];
  xdg.configFile.".tmux.xonf".source = ./. + /config/tmux;
};
