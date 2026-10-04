# Samsung SCX-3200 (USB laser MFP) shared with the LAN: CUPS for printing,
# announced over mDNS so phones and Macs find it as AirPrint; saned for
# scanning from Linux clients and the homelab scanservjs pod. Attach to the
# host the device is plugged into.
{
  flake.modules.nixos.print-server = {pkgs, ...}: {
    services = {
      printing = {
        enable = true;
        # SpliX is the free SPL driver and ships scx3200.ppd; Samsung's own
        # (unfree) samsung-unified-linux-driver is the fallback if it misprints.
        drivers = [pkgs.splix];
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

    # The queue is declared rather than made by hand; the URI is what the CUPS
    # usb backend reports for the device (`lpinfo -v`).
    hardware.printers = {
      ensurePrinters = [
        {
          name = "SCX-3200";
          description = "Samsung SCX-3200";
          location = "asus";
          deviceUri = "usb://Samsung/SCX-3200%20Series?serial=Z5IGBFFB903310T";
          model = "samsung/scx3200.ppd";
          ppdOptions.PageSize = "A4";
        }
      ];
      ensureDefaultPrinter = "SCX-3200";
    };

    # Scanning needs no extra backend: stock SANE's xerox_mfp covers 04e8:3441.
    hardware.sane.enable = true;
    # saned's control port; its data connections are tracked by the `sane`
    # conntrack helper the saned module turns on.
    networking.firewall.allowedTCPPorts = [6566];
  };
}
