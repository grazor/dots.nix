{
  lib,
  config,
  pkgs,
  ...
}: let
  username = config.grazor.user.name;
  cfg = config.grazor.linux;
in {
  config = lib.mkIf cfg.withHyprland {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        foot
      ];

      xdg.configFile."foot/foot.ini".source = ./. + /raw/foot.ini;

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = ''
          monitor=,preferred,auto,1
          monitor=,highrr,auto,1

          input {
              kb_layout=us,ru
              kb_variant=
          	kb_options=grp:win_space_toggle,grp:shift_caps_switch,grp_led:caps,compose:ralt
              kb_rules=

              follow_mouse=1

              touchpad {
                  natural_scroll=yes
                  disable_while_typing=false
                  scroll_factor=0.4
              }
          }

          general {
              gaps_in=4
              gaps_out=15
              border_size=4
              col.active_border=0xfff5c2e7
              col.inactive_border=0xff45475a
              col.nogroup_border=0xff89dceb
              col.nogroup_border_active=0xfff9e2af
          	layout = master
          }

          decoration {
              rounding=1
          }

          animations {
              enabled=1
              bezier=overshot,0.13,0.99,0.29,1.1
          	bezier = mb, 0.10, 0.9, 0.1, 1.05
              animation=windows,1,4,overshot,slide
              animation=border,1,10,default
              animation=fade,1,10,default
              animation=workspaces,1,5,mb,slide
              animation=specialWorkspace,1,5,mb,slidevert
          }

          dwindle {
              pseudotile=1 # enable pseudotiling on dwindle
              force_split=0
          }

          master {
          	mfact=0.7
          }

          gestures {
              workspace_swipe=yes
              workspace_swipe_fingers=3
          	workspace_swipe_distance=1200
          	workspace_swipe_min_speed_to_force=0
          	workspace_swipe_cancel_ratio=0.03
          }

          exec-once=waybar
          exec-once=swaybg -i /home/g/.assets/wallpaper.png
          exec-once=foot --server
          exec-once=wlsunset -l 55.7 -L 37.8
          exec-once=mako
          exec-once=hyprctl setcursor 'Nordzy-cursors' 28

          # remote control
          #exec-once=sunshine

          # screen sharing
          exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

          # See https://wiki.hyprland.org/Configuring/Keywords/ for more
          $mainMod = SUPER

          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          bind = $mainMod, Return, exec, footclient
          bind = $mainMod SHIFT, Q, killactive,
          bind = $mainMod SHIFT, E, exit,
          bindr= $mainMod, F2, exec, pkill wofi || wofi --show drun
          bind = $mainMod, P, pseudo, # dwindle
          bind = $mainMod, S, togglesplit, # dwindle

          bind = $mainMod, M, layoutmsg, swapwithmaster master
          bind = $mainMod, F, fullscreen,
          bind = $mainMod, Space, togglefloating,

          bind = CTRL, Space, exec, makoctl dismiss

          bind = $mainMod, F12, exec, /home/g/.bin/yubikey 30
          bind = CTRL, Print, exec, /home/g/.bin/grimshot copy screen
          bind = CTRL SHIFT, Print, exec, /home/g/.bin/grimshot copy area
          bind = SHIFT, Print, exec, /home/g/.bin/grimshot save area
          bind = $mainMod SHIFT, Print, exec, /home/g/.bin/grimshot search area
          bind = , Print, exec, /home/g/.bin/grimshot save screen

          bind = CTRL ALT, 1, exec, hyprctl keyword input:kb_layout us
          bind = CTRL ALT, 2, exec, hyprctl keyword input:kb_layout ru

          windowrulev2 = float,class:(Mattermost),title:(.*)
          windowrulev2 = workspace special mm,class:(Mattermost),title:(.*)
          windowrulev2 = size 95% 95%,class:(Mattermost),title:(.*)
          windowrulev2 = center,class:(Mattermost),title:(.*)
          windowrulev2 = opacity 0.97,class:(Mattermost),title:(.*)
          #windowrulev2 = stayfocused,class:(Mattermost),title:(.*)

          windowrulev2 = float,class:(obsidian),title:(.*)
          windowrulev2 = workspace special obs,class:(obsidian),title:(.*)
          windowrulev2 = size 95% 95%,class:(obsidian),title:(.*)
          windowrulev2 = center,class:(obsidian),title:(.*)
          windowrulev2 = opacity 0.97,class:(obsidian),title:(.*)
          #windowrulev2 = stayfocused,class:(obsidian),title:(.*)

          # no gaps when only
          workspace = w[tv1], gapsout:0, gapsin:0
          workspace = f[1], gapsout:0, gapsin:0
          windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
          windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
          windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
          windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

          bind = $mainMod, O, togglespecialworkspace, mm
          bind = $mainMod, Grave, togglespecialworkspace, obs

          # Move focus with mainMod + arrow keys
          bind = $mainMod, left, movefocus, l
          bind = $mainMod, right, movefocus, r
          bind = $mainMod, up, movefocus, u
          bind = $mainMod, down, movefocus, d

          bind = $mainMod, H, movefocus, l
          bind = $mainMod, L, movefocus, r
          bind = $mainMod, K, movefocus, u
          bind = $mainMod, J, movefocus, d

          # Switch workspaces with mainMod + [0-9]
          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10

          # Scroll through existing workspaces with mainMod + scroll
          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow
        '';
      };
    };
  };
}
