# Shares the host's xray proxy (modules/shared/xray.nix) with the LAN: the
# homelab cluster's `http-proxy` Service points at the nodes' :9998
# (infrastructure/http-proxy/endpointslice.yaml). Use it together with `xray`.
{
  flake.modules.nixos.proxy = {
    # Deliberately LAN-facing; xray listens on all interfaces.
    networking.firewall.allowedTCPPorts = [9998];
  };
}
