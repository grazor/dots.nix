{ ... }:

{
  imports = [
    ./hass.nix
    ./mqtt.nix
    ./zigbee2mqtt.nix
    ./caddy.nix
    ./influx.nix
    ./grafana.nix
    
    ./transmission.nix
    ./radarr.nix
    ./sonarr.nix
    ./jackett.nix
    ./plex.nix
  ];
}

