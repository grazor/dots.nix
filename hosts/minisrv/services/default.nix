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

    ./syncthing.nix

    #./tunnel.nix
    #./radarr.nix
    #./sonarr.nix
    #./jackett.nix
    #./transmission.nix
    #./plex.nix
    #./registry.nix

    #./siyuan.nix
    # ./pihole.nix
    #./couchdb.nix
    #./jellyfin.nix

    ./fleeting-chat.nix
  ];
}
