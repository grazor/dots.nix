{ config, pkgs, ... }:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = false;

    media-session.config.bluez-monitor.rules = [
      {
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.msbc-support" = true;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }

          { "node.name" = "~bluez_output.*"; }
        ];
        actions = { "node.pause-on-idle" = false; };
      }
    ];
  };

  environment.systemPackages = with pkgs; [ pulseaudio pavucontrol ];
}
