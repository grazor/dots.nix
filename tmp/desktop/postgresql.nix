{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 12 ''
      local all all trust
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
    '';

    settings = {
      log_min_error_statement = "DEBUG5";
      log_min_messages = "DEBUG5";
      logging_collector = "on";
      log_statement = "all";
      log_directory = "/tmp/pglog";
      log_filename = "postgresql-%d.log";
    };

    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE ostrovok WITH LOGIN PASSWORD 'ostrovok' SUPERUSER;

      CREATE DATABASE billing;
      GRANT ALL PRIVILEGES ON DATABASE billing TO ostrovok;
    '';
  };
}
