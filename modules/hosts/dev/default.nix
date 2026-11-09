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
        common-packages
        lxc-guest
        ssh-server
        ssh-client
        sops
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
        window_days = 365
        max_concurrent = 1

        [fill]
        default_policy = "require_covered"
      '';
    in {
      system.stateVersion = "26.05";

      users.users.cloud.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQf7B1ov8YOxL18iI9In3zNi8Q/S/8R5DB2NOndExd s22u"
      ];

      environment.etc."surfr/candles.toml".source = candlesConfig;
      environment.variables.SURFR_CANDLES_ENDPOINT = "unix:/var/lib/surfr-candles/store/candles.sock";

      # Install a release build from ~/src/surfr to this stable path. Keeping
      # the executable outside the checkout lets development builds continue.
      systemd.services.surfr-candles = {
        description = "Surfr candle dataset service (hourly MOEX ingest)";
        restartTriggers = [candlesConfig];
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

      # A resumable backfill uses the daemon's RPC API, so stored
      # coverage stays available during long, provider-paced downloads.
      systemd.services.surfr-candles-backfill = {
        description = "Backfill committed Surfr research universes";
        wantedBy = ["multi-user.target"];
        wants = ["surfr-candles.service"];
        after = ["surfr-candles.service"];
        path = [pkgs.grpcurl];
        unitConfig = {
          ConditionPathExists = [
            "/var/lib/surfr-candles/backfill/run.py"
            "/var/lib/surfr-candles/backfill/plan.json"
          ];
          OnSuccess = ["surfr-candles-scan.service"];
        };
        serviceConfig = {
          Type = "exec";
          User = "cloud";
          Group = "users";
          StateDirectory = "surfr-candles";
          WorkingDirectory = "/var/lib/surfr-candles/backfill";
          StateDirectoryMode = "0750";
          ExecStart = "${pkgs.python3}/bin/python3 /var/lib/surfr-candles/backfill/run.py run --plan plan.json --status status.json --proto /var/lib/surfr-candles/backfill/candles.proto";
          Restart = "on-failure";
          RestartSec = 3600;
          Nice = 10;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          UMask = "0027";
        };
      };

      # Runs only after a successful backfill. It owns the brief stop/scan/
      # restart sequence, since the CLI scanner requires the writer lock.
      systemd.services.surfr-candles-scan = {
        description = "Scan completed Surfr backfill for corporate actions";
        path = [pkgs.util-linux];
        serviceConfig = {
          Type = "oneshot";
          ExecCondition = "${pkgs.python3}/bin/python3 /var/lib/surfr-candles/backfill/run.py ready --status /var/lib/surfr-candles/backfill/status.json";
          ExecStart = "${pkgs.python3}/bin/python3 /var/lib/surfr-candles/backfill/run.py finalize --plan /var/lib/surfr-candles/backfill/plan.json --status /var/lib/surfr-candles/backfill/status.json";
          TimeoutStartSec = "infinity";
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

      # Codex looks for tmux in trusted system paths when forwarding clipboard
      # copies; Home Manager's per-user profile is not searched.
      environment.systemPackages = [pkgs.tmux];

      users.users.cloud.linger = true;
      home-manager.users.cloud.imports = with config.flake.modules.homeManager; [
        tmux-autostart
        agent-dev
        codex-dev
      ];

      # The dev container has no local GUI clipboard. Send copied text through
      # the SSH terminal with OSC 52; the Mac's tmux relays it to Ghostty.
      home-manager.users.cloud.programs.tmux.extraConfig = ''
        set-option -g set-clipboard on
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
      '';

      # Neovim visual yanks use the same tmux clipboard path. Read back from
      # tmux's own paste buffer so `p` does not wait for an OSC 52 read reply.
      home-manager.users.cloud.programs.nvf.settings.vim.luaConfigRC.devClipboard = ''
        vim.g.clipboard = {
          name = "tmux OSC 52",
          copy = {
            ["+"] = {"tmux", "load-buffer", "-w", "-"},
            ["*"] = {"tmux", "load-buffer", "-w", "-"},
          },
          paste = {
            ["+"] = {"tmux", "save-buffer", "-"},
            ["*"] = {"tmux", "save-buffer", "-"},
          },
          cache_enabled = 1,
        }
      '';
    };
  };
}
