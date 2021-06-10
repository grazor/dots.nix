{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 20;

      modules-left = [ "sway/workspaces" "sway/mode" ];

      modules-center = [ "clock#date" "clock#time" ];

      modules-right = [ "network" "memory" "cpu" "temperature" "battery" "pulseaudio" "tray" ];

      modules = {
        "battery" = {
          interval = 10;
          states = {
            warning = 15;
            critical = 5;
          };
          format = "  {icon}  {capacity}%";
          "format-discharging" = "{icon}  {capacity}%";
          "format-icons" = [
            ""
            "" # Icon: battery-three-quarters
            "" # Icon: battery-half
            "" # Icon: battery-quarter
            "" # Icon: battery-empty
          ];
          tooltip = true;
        };

        "clock#time" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = false;
        };

        "clock#date" = {
          interval = 10;
          format = "  {:%e %b %Y}";
          tooltip = false;
        };

        "cpu" = {
          "interval" = 5;
          "format" = "  {usage}% ({load})";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
        };

        "memory" = {
          "interval" = 5;
          "format" = "  {}%";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
        };

        "network" = {
          "interval" = 5;
          "format-wifi" = "  {essid} ({signalStrength}%)";
          "format-ethernet" = "  {ifname}= {ipaddr}/{cidr}";
          "format-disconnected" = "⚠  Disconnected";
          "tooltip-format" = "{ifname}= {ipaddr}";
        };

        "sway/mode" = {
          "format" = ''<span style="italic">  {}</span>'';
          "tooltip" = false;
        };

        "sway/workspaces" = {
          "all-outputs" = false;
          "disable-scroll" = true;
          #"format"= "{icon} {name}";
          "format" = "{name}";
          "format-icons" = {
            "1=www" = "龜";
            "2=mail" = "";
            "3=editor" = "";
            "4=terminals" = "";
            "5=portal" = "";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };

        "pulseaudio" = {
          #"scroll-step"= 1;
          "format" = "{format_source}  {icon}  {volume}%";
          "format-bluetooth" = "{format_source}  {icon}  {volume}%";
          "format-source" = ''<span color="orange"></span>'';
          "format-source-muted" = "";
          "format-muted" = "";
          "format-icons" = {
            "headphones" = "";
            "handsfree" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" ];
          };
          "on-click" = "pavucontrol";
        };

        "temperature" = {
          "critical-threshold" = 80;
          "interval" = 5;
          "format" = "{icon}  {temperatureC}°C";
          "format-icons" = [ "" "" "" "" "" ];
          "tooltip" = true;
        };

        "tray" = {
          "icon-size" = 21;
          "spacing" = 10;
        };
      };
    }];

    style = ''
      @keyframes blink-warning {
          70% {
              color: white;
          }

          to {
              color: white;
              background-color: orange;
          }
      }

      @keyframes blink-critical {
          70% {
            color: white;
          }

          to {
              color: white;
              background-color: red;
          }
      }


      /* -----------------------------------------------------------------------------
       * Base styles
       * -------------------------------------------------------------------------- */

      /* Reset all styles */
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
      }

      /* The whole bar */
      #waybar {
          background: #323232;
          color: white;
          /*font-family: Cantarell, Noto Sans, sans-serif;*/
          font-family: "Hack", "Font Awesome 5 Free";
          font-size: 13px;
      }

      /* Each module */
      #battery,
      #clock,
      #cpu,
      #custom-keyboard-layout,
      #memory,
      #mode,
      #network,
      #pulseaudio,
      #temperature,
      #tray {
          padding-left: 10px;
          padding-right: 10px;
      }


      /* -----------------------------------------------------------------------------
       * Module styles
       * -------------------------------------------------------------------------- */

      #battery {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #battery.warning {
          color: orange;
      }

      #battery.critical {
          color: red;
      }

      #battery.warning.discharging {
          animation-name: blink-warning;
          animation-duration: 3s;
      }

      #battery.critical.discharging {
          animation-name: blink-critical;
          animation-duration: 2s;
      }

      #clock {
          font-weight: bold;
      }

      #cpu {
        /* No styles */
      }

      #cpu.warning {
          color: orange;
      }

      #cpu.critical {
          color: red;
      }

      #memory {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #memory.warning {
          color: orange;
      }

      #memory.critical {
          color: red;
          animation-name: blink-critical;
          animation-duration: 2s;
      }

      #mode {
          background: #64727D;
          border-top: 2px solid white;
          /* To compensate for the top border and still have vertical centering */
          padding-bottom: 2px;
      }

      #network {
          /* No styles */
      }

      #network.disconnected {
          color: orange;
      }

      #pulseaudio {
          /* No styles */
      }

      #pulseaudio.muted {
          /* No styles */
      }

      #custom-spotify {
          color: rgb(102, 220, 105);
      }

      #temperature {
          /* No styles */
      }

      #temperature.critical {
          color: red;
      }

      #tray {
          /* No styles */
      }

      #window {
          font-weight: bold;
      }

      #workspaces button {
          border-top: 1px solid transparent;
          /* To compensate for the top border and still have vertical centering */
          padding-bottom: 2px;
          padding-left: 4px;
          padding-right: 4px;
          /*padding-left: 10px;
          padding-right: 10px;*/
          color: #888888;
      }

      #workspaces button.focused {
          border-color: #4cb899;
          /*border-color: #4c7899;*/
          color: white;
          background-color: #285577;
      }

      #workspaces button.urgent {
          border-color: #c9545d;
          color: #c9545d;
      }
    '';

  };
}
