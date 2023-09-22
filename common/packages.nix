{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    ffmpeg
    unar
    tree
    patchelf
    bind
    ncdu
    curl

    direnv
    brightnessctl
    zoxide
  ];
}
