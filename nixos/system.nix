{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    cleanTmpDir = true;
  };

  services.acpid.enable = true;
  services.sshd.enable = true;

  powerManagement.enable = true;

  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  services.resolved.enable = true;
  services.resolved.fallbackDns = [ "8.8.8.8" "10.0.0.1" ];
  services.pptpd.enable = true;

  services.pcscd.enable = true;
  services.dbus.packages = [ pkgs.gcr ];
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "curses";
     enableSSHSupport = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  environment.systemPackages = with pkgs; [
    glibc.out
    update-systemd-resolved
    ppp

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
    libnotify

    direnv
    brightnessctl 
    zoxide # smart cd
    exa # fancy ls
  ];
}
