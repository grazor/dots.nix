# Incus: throwaway LXC containers next to Docker, behind the host firewall.
# What to store where and which profiles exist is the host's business
# (`virtualisation.incus.preseed`); this aspect only makes the daemon work.
{
  flake.modules.nixos.incus = {
    # incus-lts. Members of `incus-admin` drive it with `incus` without sudo.
    virtualisation.incus.enable = true;

    # Incus refuses to run behind an iptables-based firewall, so switch the
    # NixOS firewall to nftables. Docker keeps working: nixpkgs' `iptables` is
    # the nft-compat build, so its rules live in the same nftables ruleset.
    networking.nftables.enable = true;

    # Docker sets FORWARD to DROP when it is the one turning forwarding on,
    # which silently cuts the container bridge off from the LAN. Forwarding
    # on from boot means Docker leaves the policy alone.
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    # Containers get DHCP and DNS from incusd's dnsmasq on the bridge.
    networking.firewall.trustedInterfaces = ["incusbr0"];
  };
}
