# Desktop PC — gaming workstation (GNOME + NVIDIA + Steam, user `g`).
{mkNixos, ...}: {
  flake.nixosConfigurations.desktop = mkNixos {
    aspects = m:
      with m; [
        common
        wireless
        docker
        pipewire
        graphics-intel
        graphics-nvidia
        udev
        gnome
        gui-apps
        zen
        gaming
        qmk
        ssh-server
        tools
        devtools
        fonts
        user-g
      ];

    machine = {lib, ...}: {
      networking.hostName = "desktop";
      system.stateVersion = "25.05";
      nix.settings.max-jobs = lib.mkDefault 8;

      # Regenerate on the device:
      #   sudo nixos-facter -o modules/hosts/desktop/facter.json
      facter.reportPath = ./facter.json;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/1c2eeb31-ea2c-42ae-9c39-645a52310687";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/C87A-FB49";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      hardware.bluetooth.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
    };
  };
}
