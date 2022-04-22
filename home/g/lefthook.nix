{ pkgs, ... }:

{
  home.packages = with pkgs; [ lefthook ];
  xdg.configFile."lefthook/general.yml".source = ./. + /config/lefthook.general.yml;
}
