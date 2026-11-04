# Persistent Incus development container.
{
  config,
  mkNixos,
  ...
}: {
  flake.nixosConfigurations.dev = mkNixos {
    aspects = m:
      with m; [
        base
        lxc-guest
        ssh-server
        tools
        devtools
        agent-dev
        user-cloud
      ];

    machine = {
      lib,
      pkgs,
      ...
    }: let
      candlesConfig = pkgs.writeText "candles.toml" ''
        store_dir = "/var/lib/surfr-candles/store"
        listen = "unix:/var/lib/surfr-candles/store/candles.sock"

        [source.moex]
        # Public delayed ISS data; no subscription credential is needed.
        token = "anonymous"
        base_url = "https://iss.moex.com"
        iss_base_url = "https://iss.moex.com"

        [ingest]
        poll_interval_sec = 3600
        window_days = 1
        max_concurrent = 1

        [fill]
        default_policy = "require_covered"
      '';
    in {
      system.stateVersion = "26.05";

      environment.etc."surfr/candles.toml".source = candlesConfig;
      environment.variables.SURFR_CANDLES_ENDPOINT = "unix:/var/lib/surfr-candles/store/candles.sock";

      # Install a release build from ~/src/surfr to this stable path. Keeping
      # the executable outside the checkout lets development builds continue.
      systemd.services.surfr-candles = {
        description = "Surfr candle dataset service (hourly MOEX ingest)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];
        unitConfig = {
          ConditionFileIsExecutable = "/var/lib/surfr-candles/bin/candles";
          StartLimitIntervalSec = 3600;
          StartLimitBurst = 5;
        };
        environment = {
          RUST_LOG = "candles=info";
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };
        serviceConfig = {
          Type = "exec";
          User = "cloud";
          Group = "users";
          StateDirectory = "surfr-candles";
          StateDirectoryMode = "0750";
          WorkingDirectory = "/var/lib/surfr-candles";
          ExecStart = "/var/lib/surfr-candles/bin/candles serve --config /etc/surfr/candles.toml";
          Restart = "on-failure";
          RestartSec = 300;
          TimeoutStopSec = 30;
          UMask = "0027";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      systemd.network.networks."50-eth0" = {
        networkConfig.DHCP = lib.mkForce "no";
        address = ["192.168.2.64/24"];
        gateway = ["192.168.2.1"];
        dns = ["192.168.2.1"];
      };

      nix.settings = {
        max-jobs = lib.mkDefault 2;
        cores = lib.mkDefault 4;
      };

      users.users.cloud.linger = true;
      home-manager.users.cloud.imports = with config.flake.modules.homeManager; [
        agent-dev
        codex-dev
      ];
    };
  };
}
