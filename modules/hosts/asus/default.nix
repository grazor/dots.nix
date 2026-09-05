# Asus node — homelab k3s agent/worker (headless, user `cloud`), and the box
# the HP USB printer/scanner is plugged into.
{mkNixos, ...}: {
  flake.nixosConfigurations.asus = mkNixos {
    aspects = m:
      with m; [
        common
        proxy
        docker
        pipewire
        graphics-intel
        udev
        headless
        k3s-base
        k3s-agent
        ssh-server
        sops
        #print-server
        tools
        mediatools
        devtools
        fonts
        user-cloud
      ];

    machine = {lib, ...}: {
      networking.hostName = "asus";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 8;

      systemd.tpm2.enable = false;

      # Pin k3s to the wired NIC. The box holds DHCP leases on both enp2s0
      # (192.168.2.31) and wlan0 (192.168.2.20); k3s picks by default route,
      # and when it lands on wlan0 the flannel VXLAN endpoint moves to Wi-Fi
      # with it. Control traffic survives that, but Longhorn's engine-to-replica
      # writes do not: replicas report "Failed to write" and the engine never
      # leaves `starting`, so volumes hang in `attaching`.
      services.k3s.extraFlags = lib.mkForce (toString [
        "--node-ip=192.168.2.31"
        "--flannel-iface=enp2s0"
      ]);
      services.resolved.enable = lib.mkForce false;

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/asus/facter.json
      facter.reportPath = ./facter.json;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/d6695e03-8225-43e7-9ae7-1c57b92c1e8b";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/A1F1-D59A";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
      swapDevices = [{device = "/dev/disk/by-uuid/beea70c6-7048-49c3-8094-0b7eeae24e95";}];

      hardware.bluetooth.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

      # Print and scan over USB from a local shell too. The queue itself is
      # made once with `sudo hp-setup -i`; to pin it here instead, use
      # hardware.printers.ensurePrinters with the URI from `lpinfo -v` and
      # the model from `lpinfo -m`.
      users.users.cloud.extraGroups = ["lp" "scanner"];
    };
  };
}
