{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor.linux.wireguardServer;
in {
  options.grazor.linux.wireguardServer = {
    enable = lib.mkEnableOption "WireGuard VPN server for remote home-network access";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "Name of the WireGuard interface.";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "UDP port WireGuard listens on. Forward this port on the router to this host.";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.1/24";
      description = "Server address inside the WireGuard tunnel.";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.0/24";
      description = "WireGuard tunnel subnet that gets masqueraded onto the LAN.";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/wireguard/wg0.key";
      description = "Path to the server private key. Auto-generated on first boot if missing.";
    };

    peers = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [];
      example = lib.literalExpression ''
        [
          {
            publicKey = "<client public key>";
            allowedIPs = ["10.100.0.2/32"];
          }
        ]
      '';
      description = "WireGuard client peers (each with publicKey and allowedIPs).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.wireguard-tools];

    # Route VPN client traffic on to the rest of the home network.
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # Let the wireguard-${interface} service own the tunnel device.
    networking.networkmanager.unmanaged = ["interface-name:${cfg.interface}"];

    networking.wireguard.interfaces.${cfg.interface} = {
      ips = [cfg.address];
      listenPort = cfg.listenPort;

      # Generated on the host on first activation; never stored in the repo.
      inherit (cfg) privateKeyFile;
      generatePrivateKeyFile = true;

      # Masquerade tunnel traffic so clients can reach every device on the LAN
      # (and the internet) without per-device static routes.
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.subnet} -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.subnet} -j MASQUERADE
      '';

      inherit (cfg) peers;
    };
  };
}
