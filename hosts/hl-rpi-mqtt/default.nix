{lib, pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.networkmanager.wifi.powersave = false;

  networking.hostName = "hl-rpi-mqtt";
  system.stateVersion = "25.05";

  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;

  # common without bootloader
  services = {
    acpid.enable = true;
    pcscd.enable = true;
    dbus.packages = [pkgs.gcr];
  };

  networking.networkmanager.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    glibc.out

    acpi
    binutils
    findutils
    htop
    usbutils
    nettools

    bind
    bridge-utils
    inetutils
    iw
  ];
}
