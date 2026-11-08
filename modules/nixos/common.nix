# Shared CLI packages are available to physical hosts and the dev container.
# `common` adds the bootloader, firmware, and NetworkManager for physical hosts.
{config, ...}: {
  flake.modules.nixos.common-packages = {pkgs, ...}: {
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

  flake.modules.nixos.common = {pkgs, ...}: {
    imports = with config.flake.modules.nixos; [base common-packages];

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
      dbus.packages = [pkgs.gcr_3];
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
    # NetworkManager runs its own DHCP client. dhcpcd, still on by default,
    # finds no interface to manage and holds network-online.target for up
    # to 30s on every boot.
    networking.dhcpcd.enable = false;
  };
}
