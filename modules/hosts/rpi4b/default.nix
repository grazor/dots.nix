# Raspberry Pi 4B — native Zigbee2MQTT bridge to the k3s MQTT broker.
{mkNixos, ...}: {
  flake.nixosConfigurations.rpi4b = mkNixos {
    system = "aarch64-linux";
    aspects = m:
      with m; [
        common
        raspberry-pi-4
        headless
        ssh-server
        sops
        zigbee2mqtt-native
        user-pi
      ];

    machine = {lib, ...}: {
      networking.hostName = "rpi4b";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 2;

      systemd.tpm2.enable = false;
      services.acpid.enable = lib.mkForce false;
      services.pcscd.enable = lib.mkForce false;

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/rpi4b/facter.json
      facter.reportPath = ./facter.json;

      # Replace this UUID after preparing the SD card / USB SSD. With the
      # standard NixOS aarch64 SD-card layout, extlinux lives in /boot on the
      # root filesystem and Raspberry Pi firmware lives on /boot/firmware.
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/REPLACE_ME_ROOT_UUID";
        fsType = "ext4";
      };
      fileSystems."/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = ["nofail" "noauto"];
      };

      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };
  };
}
