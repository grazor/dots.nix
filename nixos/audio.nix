{ config, pkgs, ... }:

{
  # Use pulse for now
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; # # If compatibility with 32-bit applications is desired.
  nixpkgs.config.pulseaudio = true;

  # Temporarily disabled
  #security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    pulse.enable = true;

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
