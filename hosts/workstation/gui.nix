{ pkgs, config, ... }:

{

  # Blacklist nvidia
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
  ];
  # End

  # Prevent graphical corruption
  #powerManagement.enable = true

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    synaptics = {
      enable = true;
      vertTwoFingerScroll = true;
      vertEdgeScroll = false;
      minSpeed = "0.8";
      additionalOptions = "	Option \"VertScrollDelta\" \"-27\"\n	Option \"HorizScrollDelta\" \"-27\"\n";
    };

    windowManager.i3 = {
      enable = true;
    };
  };

  services = {
    libinput.enable = false;
    displayManager.defaultSession = "hyprland";
  };

  hardware.uinput.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    "NIXOS_OZONE_WL" = "1";
    "QT_QPA_PLATFORM" = "xcb";
    "QT_QPA_PLATFORMTHEME" = "qt5ct";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "LIBVA_DRIVER_NAME" = "i965";

    "WLR_NO_HARDWARE_CURSORS" = "1";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    mpv
    blender
    iwgtk
    feh
    inkscape
    gimp
    tdesktop
    obsidian

    rose-pine-cursor
    nordzy-cursor-theme

    wayvnc
    #sunshine
    rustdesk
  ];
}
