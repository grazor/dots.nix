{ pckgs, ... }:

{
  home.packages = with pkgs; [
    termite # terminal emulator
  ];

  xdg.configFile."termite/config".source = ./. + /config/termite;
}
