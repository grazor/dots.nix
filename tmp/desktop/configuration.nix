{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./nvidia.nix ./postgresql.nix ./vim.nix ./steam.nix ./steamcontroller.nix ];

  time.timeZone = "Europe/Moscow";

  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 3;
      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = { "fs.inotify.max_user_watches" = 100000; };
    #kernelPackages = pkgs.linuxPackages_latest;
    cleanTmpDir = true;
  };

  powerManagement.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  security.rtkit.enable = true;

  console.font = "latarcyrheb-sun32";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;

  networking = {
    hostName = "porivaev";

    firewall = {
      enable = false;
      allowedTCPPorts = [
        3000 # Development
        8000 # Development
      ];
      allowPing = true;
    };

    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    bash
    binutils
    file
    bridge-utils
    efibootmgr
    findutils
    hicolor_icon_theme
    htop
    inetutils
    iw
    ntfs3g
    openvpn
    unzip
    wget
    wirelesstools
    git
    jq
    xdg_utils
    mpv

    go
    gotools
    delve
    python
    docker
    gnumake

    networkmanager_openvpn
    usbutils

    nox
    direnv

    slack
    termite
    google-chrome
    nixfmt
    gimp
    tdesktop
    zoom-us

    v4l-utils

    rofi
    mako
    mesa
    mesa_drivers
    sway
    grim
    slurp
    waybar
    wl-clipboard
    wineWowPackages.stable
    libnotify
    pavucontrol
    xdg-user-dirs
  ];

  services.acpid.enable = true;
  services.logind.lidSwitch = "suspend";
  services.sshd.enable = true;
  programs.ssh.askPassword = "";

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", SYMLINK+="arduino"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0x10c4", ATTRS{idProduct}=="0xea60", MODE="0666", SYMLINK+="esp32"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0666", SYMLINK+="ttyArduinoUno"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", SYMLINK+="ttyArduinoNano2"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", SYMLINK+="ttyArduinoNano"

    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a0", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11a0", ATTRS{idProduct}=="db20", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11a0", ATTRS{idProduct}=="eb20", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a2", MODE="0666"

    SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", ATTRS{product}=="C922 Pro Stream Webcam", RUN="v4l2-ctl -d $devnode --set-ctrl=zoom_absolute=120 --set-ctrl=backlight_compensation=1"
  '';

  location.provider = "geoclue2";

  programs.sway.enable = true;
  services.xserver = {
    enable = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3lock ];
    };
  };

  programs.bash.enableCompletion = true;
  programs.adb.enable = true;

  programs.zsh.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "pip" ];
    theme = "agnoster";
  };
  programs.zsh.shellAliases = { };

  virtualisation.docker.enable = true;

  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";
  users.users.g = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "network" "uucp" "dialout" "networkmanager" "docker" "audio" "video" "input" "sway" ];
    useDefaultShell = true;
  };

  services.redis.enable = true;

  nix.trustedUsers = [ "root" "@wheel" ];
  nix.extraOptions = ''
    experimental-features = nix-command
  '';

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    useSandbox = true;
    package = pkgs.nixUnstable;
  };

  system.stateVersion = "20.03";
}
