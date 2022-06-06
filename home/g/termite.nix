{ pkgs, ... }:

{
  home.packages = with pkgs; [
    termite # for i3
    foot # for sway
  ];

  # i3, still keep it
  xdg.configFile."termite/config".source = ./. + /config/termite;

  xdg.configFile."foot/foot.ini".source = ./. + /config/foot.ini;
}
