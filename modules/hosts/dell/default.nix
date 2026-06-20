# Dell laptop — homelab k3s server + WireGuard server (headless, user `cloud`).
{mkNixos, ...}: {
  flake.nixosConfigurations.dell = mkNixos {
    aspects = m:
      with m; [
        common
        wireless
        proxy
        wireguard-server
        docker
        pipewire
        graphics-intel
        udev
        battery
        headless
        k3s-base
        k3s-server
        flux-bootstrap
        ssh-server
        sops
        tools
        devtools
        fonts
        user-cloud
      ];

    machine = {lib, ...}: {
      networking.hostName = "dell";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 8;

      systemd.tpm2.enable = false;
      # k3s/CoreDNS handle DNS; systemd-resolved is forced off here.
      services.resolved.enable = lib.mkForce false;

      # Hardware is detected by nixos-facter. Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/dell/facter.json
      facter.reportPath = ./facter.json;

      # facter does not manage mounts — declare them explicitly.
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/65b0d516-76fe-4a82-bd43-ab937680d82b";
        fsType = "ext4";
      };
      boot.initrd.luks.devices."luks-8da9eb70-9a52-4935-82ca-69d39e465873".device = "/dev/disk/by-uuid/8da9eb70-9a52-4935-82ca-69d39e465873";
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/A2D3-9A85";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      hardware.bluetooth.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };
  };
}
