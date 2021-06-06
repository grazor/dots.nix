{ config, pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      anonymousPro
      corefonts
      dejavu_fonts
      freefont_ttf
      google-fonts
      inconsolata
      iosevka
      liberation_ttf
      meslo-lg
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      powerline-fonts
      source-code-pro
      terminus_font
      ubuntu_font_family
    ];
  };

  environment.systemPackages = with pkgs; [ google-chrome mpv termite ];
}
