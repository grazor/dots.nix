{ ... }:

{
  imports = [
    ./hass.nix
    ./mqtt.nix
    ./zigbee2mqtt.nix
    ./caddy.nix
    ./influx.nix
    ./grafana.nix
    
    #./tunnel.nix
    #./radarr.nix
    #./sonarr.nix
    #./jackett.nix
    #./transmission.nix
    #./plex.nix

    #./registry.nix
  ];
}

