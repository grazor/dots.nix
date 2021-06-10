{ pkgs, lib, config, ... }:

with lib;

{
  imports = [ ./mako.nix ./waybar.nix ];

  home.packages = with pkgs; [
    swaylock # lockscreen
    swayidle # idle manager
    waybar # bar
    wofi # launcher
    mako # notification daemon
    termite # terminal emulator
    kanshi # hotplug displays

    wl-clipboard # clipboard tool
    clipman # clipboard manager
    slurp # screen area selection
    grim # image grabber

    flashfocus # window focus animation
    autotiling # smart tiling
  ];

  wayland.windowManager.sway = let
    wallpaperCommand = "find ~/.wallpapers/* | shuf -n 1";
    lockCommand = "swaylock -i `${wallpaperCommand}`";
  in {
    enable = true;
    wrapperFeatures.gtk = true;

    extraConfig = ''
      for_window [class="Slack"] move to scratchpad
      default_border pixel
    '';

    config = rec {
      terminal = "termite";
      menu = "wofi --show drun";
      modifier = "Mod4";

      output = {
        "eDP-1" = {
          resolution = "1920x1080";
          scale = "1";
          #bg = "`${wallpaperCommand}` fill";
        };
        "HDMI-A-1" = {
          resolution = "1920x1080";
          scale = "1";
          #bg = "`${wallpaperCommand}` fill";
        };
      };

      input = {
        "*" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:shift_caps_switch,grp_led:caps,compose:ralt";
        };

        "1739:52632:CUST0001:00_06CB:CD98_Touchpad" = { natural_scroll = "enabled"; };

        "1739:52632:CUST0001:00_06CB:CD98_Mouse" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "disabled";
        };
      };

      bindkeysToCode = true;
      keybindings = mkOptionDefault {
        # Push-to-talk
        "F1" = "exec pactl set-source-mute @DEFAULT_SOURCE@ off";
        "--release F1" = "exec pactl set-source-mute @DEFAULT_SOURCE@ on";
        "${modifier}+F1" = "exec pactl set-source-mute @DEFAULT_SOURCE@ off";
        "${modifier}+Shift+F1" = "exec pactl set-source-mute @DEFAULT_SOURCE@ on";
        "Ctrl+space" = "exec makoctl dismiss";

        "${modifier}+F2" = "exec ${menu}";
        "${modifier}+F3" = "exec --no-startup-id clipman pick -t wofi";

        # Display slack on top of all apps
        "${modifier}+o [class=\"Slack\"]" = "scratchpad show, resize set 90 ppt 90 ppt, move position center";
      };

      startup = [
        {
          command = "systemctl --user restart mako";
          always = true;
        }
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
        {
          command = "pactl set-source-mute @DEFAULT_SOURCE@ off";
          always = false;
        }
        {
          command = "wl-paste -t text --watch clipman store";
          always = false;
        }
        {
          command = "flashfocus";
          always = true;
        }
        {
          command = "autotiling";
          always = true;
        }
      ];

      bars = [ ];
    };
  };
}
