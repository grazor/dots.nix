{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withCommon = lib.mkEnableOption "with common options";
  config = lib.mkIf cfg.withCommon {
    boot = {
      loader = {
        systemd-boot.enable = true;
        timeout = 1;
        efi.canTouchEfiVariables = true;
      };
      tmp.cleanOnBoot = true;
    };

    services = {
      acpid.enable = true;
      pcscd.enable = true;
      dbus.packages = [pkgs.gcr];
      sshd.enable = true;
      openssh.settings.PasswordAuthentication = false;

      resolved.enable = true;
      resolved.fallbackDns = [
        "8.8.8.8"
        "10.0.0.1"
      ];
    };

    networking.networkmanager.enable = true;

    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

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
      brightnessctl
      ffmpeg
      findutils
      htop
      libnotify
      ntfs3g
      usbutils
      xdg-utils

      bind
      bridge-utils
      inetutils
      iw
      openvpn
    ];
  };
}
