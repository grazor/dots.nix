{pkgs, ...}: {
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

  environment.systemPackages = with pkgs; [
    glibc.out

    direnv
    nh
    patchelf

    acpi
    binutils
    brightnessctl
    ffmpeg
    findutils
    htop
    libnotify
    ntfs3g
    tree
    unar
    unzip
    usbutils
    xdg-utils

    bind
    bridge-utils
    curl
    inetutils
    iw
    openvpn

    ncdu
    dua # <- aka ncdu
  ];
}
