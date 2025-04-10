{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withPipewire = lib.mkEnableOption "with pipewire";
  config = lib.mkIf cfg.withPipewire {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [pulseaudio pavucontrol];
  };
}
