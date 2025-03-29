_: {
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

    ./fleeting-chat.nix
  ];
}
