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
        ssh-server
        sops
        tools
        mediatools
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
      # Single unencrypted ext4 root plus the EFI system partition, both
      # addressed by label so a reinstall does not change the config:
      #   mkfs.fat -F32 -n BOOT <esp> ; mkfs.ext4 -L nixos <root>
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      hardware.bluetooth.enable = true;
    };
  };
}
