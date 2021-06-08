{ config, pkgs, ... }:

{
    services.home-assistant = {
    enable = true;
    port = 8123;
    config = {
      homeassistant = {
        name = "Home";
        time_zone = "Europe/Moscow";
        latitude = 55;
        longitude = 37;
        elevation = 1;
        unit_system = "metric";
        temperature_unit = "C";
      };
      # Enable the frontend
      frontend = { };
    };
  };
}
