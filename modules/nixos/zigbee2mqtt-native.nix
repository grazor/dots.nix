# Native Zigbee2MQTT role for a small node with the USB coordinator attached.
# The MQTT broker lives in k3s and is reached through its MetalLB address.
{
  flake.modules.nixos.zigbee2mqtt-native = {config, ...}: let
    mqttPasswordSecret = "zigbee2mqtt-mqtt-password";
  in {
    sops.secrets.${mqttPasswordSecret} = {
      sopsFile = ../../secrets/zigbee2mqtt.yaml;
      restartUnits = ["zigbee2mqtt.service"];
    };

    sops.templates."zigbee2mqtt.env" = {
      owner = "zigbee2mqtt";
      mode = "0400";
      content = ''
        ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=${config.sops.placeholder.${mqttPasswordSecret}}
      '';
      restartUnits = ["zigbee2mqtt.service"];
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        devices = "devices.yaml";
        groups = "groups.yaml";
        homeassistant = {
          enabled = true;
          discovery_topic = "homeassistant";
          status_topic = "hass/status";
          experimental_event_entities = true;
          legacy_entity_attributes = true;
          legacy_triggers = false;
        };
        permit_join = false;
        blocklist = [];
        availability = {
          active.timeout = 10;
          passive.timeout = 1500;
        };
        mqtt = {
          server = "mqtt://192.168.10.160:1883";
          user = "z2m";
        };
        serial = {
          # Replace with the stable by-id path from the Pi:
          #   ls -l /dev/serial/by-id/
          port = "/dev/serial/by-id/REPLACE_ME_ZIGBEE_DONGLE";
          adapter = "ember";
          baudrate = 115200;
          rtscts = false;
          disable_led = true;
        };
        ota = {
          ikea_ota_use_test_url = false;
          update_check_interval = 1440;
          disable_automatic_update_check = false;
        };
        frontend = {
          enabled = true;
          host = "0.0.0.0";
          port = 8080;
        };
        advanced = {};
      };
    };

    systemd.services.zigbee2mqtt = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      environment.Z2M_ONBOARD_NO_SERVER = "1";
      serviceConfig.EnvironmentFile = config.sops.templates."zigbee2mqtt.env".path;
    };
  };
}
