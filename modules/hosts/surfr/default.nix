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
      webPort = 9990;

      hardening = {
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
      };
    in {
      system.stateVersion = "26.05";
      nix.settings.max-jobs = lib.mkDefault 4;

      environment.systemPackages = with pkgs; [
        rsync
        btop
        lsof
        claude-code
      ];

      networking.firewall.allowedTCPPorts = [webPort];

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

      systemd = {
        network.networks."50-eth0" = {
          networkConfig.DHCP = lib.mkForce "no";
          address = ["192.168.2.32/24"];
          gateway = ["192.168.2.1"];
          dns = ["192.168.2.1"];
        };

        services = {
          surfr = {
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

            serviceConfig =
              hardening
              // {
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
              };
          };

          surfr-webui = {
            description = "surfr inspect dashboard";
            wantedBy = ["multi-user.target"];
            after = ["surfr.service"];
            bindsTo = ["surfr.service"];

            unitConfig.ConditionPathExists = "${stateDir}/inspect.toml";

            serviceConfig =
              hardening
              // {
                Type = "exec";
                User = "surfr";
                Group = "surfr";
                WorkingDirectory = stateDir;
                ExecStart = "${stateDir}/bin/inspect serve --config ${stateDir}/inspect.toml";
                Restart = "always";
                RestartSec = 15;
              };
          };
        };
      };
    };
  };
}
