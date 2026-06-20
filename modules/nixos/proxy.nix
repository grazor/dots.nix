# Privoxy forwarding to the home-network SOCKS5 proxy.
{
  flake.modules.nixos.proxy = {
    services.privoxy = {
      enable = true;
      settings = {
        listen-address = "0.0.0.0:9998";
        forward-socks5 = "/ 192.168.2.1:9999 .";
      };
    };
  };
}
