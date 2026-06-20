# Asus node — homelab k3s agent/worker (headless, user `cloud`).
{mkNixos, ...}: {
  flake.nixosConfigurations.asus = mkNixos {
    aspects = m:
      with m; [
        common
        wireless
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
        tools
        devtools
        fonts
        user-cloud
      ];

    machine = {lib, ...}: {
      networking.hostName = "asus";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 8;

      systemd.tpm2.enable = false;
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
    };
  };
}
