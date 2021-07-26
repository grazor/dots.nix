{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    #kernel.sysctl = { "fs.inotify.max_user_watches" = 100000; };
    cleanTmpDir = true;
  };

  services.logind.extraConfig = ''
    HandleSuspendKey=suspend
    HandleLidSwitch=suspend
    HandleLidSwitchDocked=suspend
  '';

  services.acpid.enable = true;
  services.logind.lidSwitch = "suspend";
  services.fprintd.enable = true;
  services.sshd.enable = true;

  powerManagement.enable = true;

  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  services.pppd.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  environment.systemPackages = with pkgs; [
    glibc.out

    acpi
    binutils
    bridge-utils
    findutils
    htop
    inetutils
    iw
    nixfmt
    nox
    ntfs3g
    openvpn
    unzip
    usbutils
    wirelesstools
    xdg_utils

    exa
  ];
}
