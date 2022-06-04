{ ... }:

{
  imports = [ ./hass.nix ./mqtt.nix ./zigbee2mqtt.nix ./caddy.nix ];
  #imports = [ ./hass.nix ./mqtt.nix ./zigbee2mqtt.nix ./influx.nix ./grafana.nix ];
}

