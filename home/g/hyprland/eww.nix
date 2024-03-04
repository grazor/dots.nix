{ pkgs, lib, config, ... }:

with lib;

{
  home.packages = with pkgs; [
    eww # bar
    pamixer
    brightnessctl
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # configuration
  xdg.configFile."eww/eww.scss".source = ./eww.scss;
  xdg.configFile."eww/eww.yuck".source = ./eww.yuck;

  # scripts
  xdg.configFile."eww/scripts/battery" = {
    source = ./scripts/battery;
    executable = true;
  };

  xdg.configFile."eww/scripts/mem-ad" = {
    source = ./scripts/mem-ad;
    executable = true;
  };

  xdg.configFile."eww/scripts/memory" = {
    source = ./scripts/memory;
    executable = true;
  };

  xdg.configFile."eww/scripts/music_info" = {
    source = ./scripts/music_info;
    executable = true;
  };

  xdg.configFile."eww/scripts/pop" = {
    source = ./scripts/pop;
    executable = true;
  };

  xdg.configFile."eww/scripts/wifi" = {
    source = ./scripts/wifi;
    executable = true;
  };

  xdg.configFile."eww/scripts/workspace" = {
    source = ./scripts/workspace;
    executable = true;
  };

  xdg.configFile."eww/images/mic.png" = {
    source = ./images/mic.png;
    executable = false;
  };

  xdg.configFile."eww/images/music.png" = {
    source = ./images/music.png;
    executable = false;
  };

  xdg.configFile."eww/images/profile.png" = {
    source = ./images/profile.png;
    executable = false;
  };

  xdg.configFile."eww/images/speaker.png" = {
    source = ./images/speaker.png;
    executable = false;
  };
}

