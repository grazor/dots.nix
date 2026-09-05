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

      # The Wi-Fi radio is off entirely: this is a wired server, and leaving it
      # up gave the box a second address on the same subnet. k3s picked the
      # Wi-Fi one by default route, which moved the flannel VXLAN endpoint onto
      # Wi-Fi with it. Control traffic tolerated that, Longhorn did not -
      # replicas reported "Failed to write", the engine never left `starting`,
      # and volumes hung in `attaching`.
      boot.blacklistedKernelModules = ["iwlwifi"];

      # One NIC left, so the node IP is unambiguous; name the interface anyway
      # rather than leaving flannel to infer it. No --node-ip: the address is
      # a DHCP lease and hardcoding one that moves stops k3s from starting.
      services.k3s.extraFlags = lib.mkForce "--flannel-iface=enp2s0";
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
