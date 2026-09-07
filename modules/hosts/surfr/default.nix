{mkNixos, ...}: {
  flake.nixosConfigurations.surfr = mkNixos {
    aspects = m:
      with m; [
        base
        lxc-guest
        ssh-server
        tools
        devtools
        user-cloud
      ];

    machine = {
      lib,
      pkgs,
      ...
    }: let
      stateDir = "/var/lib/surfr";
    in {
      system.stateVersion = "26.05";
      nix.settings.max-jobs = lib.mkDefault 4;
      environment.systemPackages = with pkgs; [
        rsync
        btop
        lsof
        claude-code
      ];

      systemd.network.networks."50-eth0" = {
        networkConfig.DHCP = lib.mkForce "no";
        address = ["192.168.2.32/24"];
        gateway = ["192.168.2.1"];
        dns = ["192.168.2.1"];
      };

      users = {
        groups.surfr = {};
        users.cloud.extraGroups = ["surfr"];
        users.surfr = {
          isSystemUser = true;
          group = "surfr";
          home = stateDir;
          description = "surfr live trading host";
        };
      };

      systemd.services.surfr = {
        description = "surfr live trading host";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];

        environment = {
          SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
          SURFR_LOG_DIR = "${stateDir}/logs";
        };

        unitConfig = {
          ConditionPathExists = "${stateDir}/bin/surfr";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 3600;
        };

        serviceConfig = {
          Type = "exec";
          User = "surfr";
          Group = "surfr";
          StateDirectory = "surfr";
          StateDirectoryMode = "0750";
          WorkingDirectory = stateDir;

          EnvironmentFile = "-${stateDir}/run.env";
          ExecStart = "${stateDir}/bin/surfr run $ARGS";

          Restart = "on-failure";
          RestartSec = 30;

          TimeoutStopSec = 300;

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
        };
      };
    };
  };
}
