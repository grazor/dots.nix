{
  config,
  pkgs,
  ...
}: {
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    update-systemd-resolved
    ppp

    nh

    acpi
    binutils
    bridge-utils
    findutils
    htop
    inetutils
    iw
    nixfmt-rfc-style
    ntfs3g
    openvpn
    unzip
    usbutils
    wirelesstools
    xdg-utils
    libnotify
    ffmpeg
    unar
    tree
    patchelf
    bind
    curl

    ncdu
    dua # <- aka ncdu

    pet # cli snippet manager

    direnv
    brightnessctl
    zoxide
  ];
}
