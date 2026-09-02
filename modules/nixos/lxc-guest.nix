# NixOS as a guest in an Incus/LXC container: no kernel or bootloader, the
# runtime owns the hostname, eth0 gets DHCP from incusd. Networking mirrors
# what nixpkgs builds the stock `images:nixos` image from.
{
  flake.modules.nixos.lxc-guest = {modulesPath, ...}: {
    imports = ["${modulesPath}/virtualisation/lxc-container.nix"];

    # The flake is the configuration; keep the image from writing its own
    # configuration.nix at boot.
    installer.cloneConfig = false;

    networking = {
      # Empty on purpose: the runtime already named the UTS namespace after
      # the instance, so `incus launch ... dev` is `dev`, also in bridge DNS.
      hostName = "";
      useDHCP = false;
      dhcpcd.enable = false;
      # DNS comes from DHCP via resolved, not from the host's resolv.conf.
      useHostResolvConf = false;
    };
    systemd.network = {
      enable = true;
      networks."50-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
    services.resolved.enable = true;

    # Nobody has a password in here; the ways in are the SSH key and
    # `incus exec`, so sudo asking for one would only block.
    security.sudo.wheelNeedsPassword = false;
  };
}
