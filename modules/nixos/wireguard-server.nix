# WireGuard VPN server for remote home-network access (Dell only).
# The private key is generated on the host on first activation and never
# stored in the repo; peer public keys are public data.
{
  flake.modules.nixos.wireguard-server = {pkgs, ...}: let
    interface = "wg0";
    subnet = "10.100.0.0/24";
  in {
    environment.systemPackages = [pkgs.wireguard-tools];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    networking.networkmanager.unmanaged = ["interface-name:${interface}"];

    networking.wireguard.interfaces.${interface} = {
      ips = ["10.100.0.1/24"];
      listenPort = 51820;

      privateKeyFile = "/etc/wireguard/wg0.key";
      generatePrivateKeyFile = true;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${subnet} -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${subnet} -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "FDlPjvG6rUMJz5iN3sfSoZ1JYVHjD/tDOTrpIWzAQiY=";
          allowedIPs = ["10.100.0.2/32"];
        }
      ];
    };
  };
}
