{ ... }:

{
  imports = [
    ./hass.nix
    ./mqtt.nix
    ./zigbee2mqtt.nix
    ./caddy.nix
    ./influx.nix
    ./grafana.nix
    ./minio.nix
    ./xray.nix
    ./teamspeak.nix
    ./vaultwarden.nix

    #./siyuan.nix

    # ./pihole.nix
    ./couchdb.nix
    #./jellyfin.nix

    #./tunnel.nix
    #./radarr.nix
    #./sonarr.nix
    #./jackett.nix
    #./transmission.nix
    #./plex.nix

    #./registry.nix
  ];
}
