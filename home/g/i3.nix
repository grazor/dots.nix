{ pkgs, lib, config, ... }:

with lib;

let binPath = "/home/g" + "/.bin";
in {
  imports = [ ./mako.nix ./waybar.nix ];

  home.packages = with pkgs; [ rofi scrot xclip dunst autotiling ];

  xsession.windowManager.i3 = let
    wallpaperCommand = "find ~/.wallpapers/* | shuf -n 1";
    lockCommand = "i3lock -i `${wallpaperCommand}`";
    grimshot = "${binPath}/i3shot";
  in {
    enable = true;

    extraConfig = ''
      for_window [class="Slack"] move to scratchpad
      for_window [title="scratchterm"] move to scratchpad
      default_border pixel
    '';

    config = rec {
      terminal = "termite";
      menu = "rofi -show run";
      modifier = "Mod4";

      keybindings = mkOptionDefault {
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+0" = "workspace number 10";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "Ctrl+space" = "exec makoctl dismiss";

        "Print" = "exec ${grimshot} save screen";
        "Ctrl+Print" = "exec ${grimshot} copy screen";
        "Shift+Print" = "exec ${grimshot} save area";
        "Ctrl+Shift+Print" = "exec ${grimshot} copy area";
        "${modifier}+Shift+Print" = "exec ${grimshot} search area";

        "${modifier}+F2" = "exec ${menu}";

        # Display slack on top of all apps
        "${modifier}+grave [title=\"scratchterm\"]" =
          "scratchpad show, resize set 90 ppt 20 ppt, move position 5 ppt 80 ppt";
        "${modifier}+o [class=\"Slack\"]" =
          "scratchpad show, resize set 90 ppt 90 ppt, move position center";
        "${modifier}+minus" = "scratchpad show";
      };

      startup = [
        {
          command = "systemctl --user restart dunst";
          always = true;
          notification = false;
        }
        {
          command = "autotiling";
          always = true;
          notification = false;
        }
        {
          command = "SCRATCHTERM=1 $terminal -t scratchterm";
          always = false;
          notification = false;
        }
        {
          command = "/home/g/.bin/dsk";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
      ];

      bars = [ ];
    };
  };

  services.polybar.enable = true;
  services.polybar.script = "polybar top &";
  services.polybar.config = {
    "bar/top" = {
      monitor = "\${env:MONITOR:DVI-D-0}";

      background = "\${color.background}";
      foreground = "\${color.foreground}";

      width = "100%";
      height = "2%";
      radius = 0;
      modules-center = "date";
    };

    "color" = {
      background = "#1F1F1F";
      foreground = "#FFFFFF";
      foreground-alt = "#8F8F8F";
      module-fg = "#FFFFFF";
      primary = "#e53935";
      secondary = "#E53935";
      alternate = "#7cb342";
    };

    "module/date" = {
      type = "internal/date";
      internal = 5;
      date = "%d.%m.%y";
      time = "%H:%M";
      label = "%time%  %date%";
    };
  };
}
