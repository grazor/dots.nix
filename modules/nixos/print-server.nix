# HP USB printer/scanner shared with the LAN: CUPS for printing, announced
# over mDNS so phones and Macs find it as AirPrint; saned for scanning from
# Linux clients. Attach to the host the device is plugged into, then create
# the queue once on that host: `sudo hp-setup -i`.
{
  flake.modules.nixos.print-server = {pkgs, ...}: {
    services = {
      printing = {
        enable = true;
        # With HP's binary plugin: some models print or scan only with it, and
        # `base` already allows unfree.
        drivers = [pkgs.hplipWithPlugin];
        listenAddresses = ["*:631"];
        allowFrom = ["all"];
        browsing = true;
        defaultShared = true;
        openFirewall = true;
      };

      # cupsd registers shared queues with avahi; userServices lets it.
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      saned = {
        enable = true;
        # Who may scan: the LAN, and k3s pods (the scanservjs UI in the homelab
        # cluster reaches this over the SANE net backend; a pod on this very
        # node arrives from the pod CIDR unmasqueraded).
        extraConfig = ''
          192.168.2.0/24
          10.42.0.0/16
        '';
      };
    };

    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.hplipWithPlugin];
    };
    # saned's control port; its data connections are tracked by the `sane`
    # conntrack helper the saned module turns on.
    networking.firewall.allowedTCPPorts = [6566];
  };
}
