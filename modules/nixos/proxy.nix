# Privoxy forwarding to the home-network SOCKS5 proxy.
{
  flake.modules.nixos.proxy = {
    # Deliberately LAN-facing (privoxy listens on 0.0.0.0).
    networking.firewall.allowedTCPPorts = [9998];

    services.privoxy = {
      enable = true;
      settings = {
        listen-address = "0.0.0.0:9998";
        forward-socks5 = "/ 192.168.2.1:9999 .";
      };
    };
  };
}
