# Base configuration shared by every physical NixOS host: `base` plus the
# bootloader, firmware, NetworkManager and hardware tooling a container has
# no use for.
{config, ...}: {
  flake.modules.nixos.common = {pkgs, ...}: {
    imports = [config.flake.modules.nixos.base];

    boot = {
      loader = {
        systemd-boot.enable = true;
        systemd-boot.editor = false;
        timeout = 1;
        efi.canTouchEfiVariables = true;
      };
      tmp.cleanOnBoot = true;
    };

    services = {
      acpid.enable = true;
      pcscd.enable = true;
      dbus.packages = [pkgs.gcr];
      resolved.enable = true;
      resolved.settings.Resolve.FallbackDNS = ["1.1.1.1" "8.8.8.8"];
      logrotate.checkConfig = false;
    };

    # Detected hardware comes from nixos-facter per host; keep firmware on.
    hardware.enableRedistributableFirmware = true;

    networking = {
      networkmanager.enable = true;
      # Firewall on everywhere; each aspect opens only the ports it owns.
      firewall.enable = true;
    };
    systemd.services.NetworkManager-wait-online.enable = false;

    environment.systemPackages = with pkgs; [
      direnv
      nh
      patchelf
      nix-inspect

      glibc.out
      acpi
      binutils
      brightnessctl
      findutils
      htop
      libnotify
      ntfs3g
      usbutils
      xdg-utils
      xdg-user-dirs
      nettools

      bind
      bridge-utils
      inetutils
      iw
      openvpn
    ];
  };
}
