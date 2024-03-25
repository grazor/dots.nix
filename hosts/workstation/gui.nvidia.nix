{ pkgs, config, ... }:

let
  sunshineWithCuda = pkgs.sunshine.override { cudaSupport = true; };

  #revision from https://github.com/keylase/nvidia-patch to use
  rev = "cb0136eab688ffa44c217218f31fe2149477ada3";
  hash = "sha256-awwk9W06Pq7zoWt1FYZGEQXNYUP6Rr1iocCu1KTgsM4=";

  # create patch functions for the specified revision
  nvidia-patch = pkgs.nvidia-patch rev hash;

  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "550.54.14";
    sha256_64bit = "sha256-jEl/8c/HwxD7h1FJvDD6pP0m0iN7LLps0uiweAFXz+M=";
    sha256_aarch64 = "sha256-sProBhYziFwk9rDAR2SbRiSaO7RMrf+/ZYryj4BkLB0=";
    openSha256 = "sha256-F+9MWtpIQTF18F2CftCJxQ6WwpA8BVmRGEq3FhHLuYw=";
    settingsSha256 = "sha256-m2rNASJp0i0Ez2OuqL+JpgEF0Yd8sYVCyrOoo/ln2a4=";
    persistencedSha256 = "sha256-XaPN8jVTjdag9frLPgBtqvO/goB5zxeGzaTU0CdL6C4=";
  };
in {
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
      defaultSession = "hyprland";
    };
    libinput.enable = false;
  };

  hardware.uinput.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    #package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc nvidiaPackage);
    #package = nvidia-patch.patch-nvenc nvidiaPackage;
    package = nvidiaPackage;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.sessionVariables = rec {
    "NIXOS_OZONE_WL" = "1";
    "QT_QPA_PLATFORM" = "xcb";
    "QT_QPA_PLATFORMTHEME" = "qt5ct";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";

    "LIBVA_DRIVER_NAME" = "nvidia";
    "XDG_SESSION_TYPE" = "wayland";
    "GBM_BACKEND" = "nvidia-drm";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "WLR_NO_HARDWARE_CURSORS" = "1";

    #"__NV_PRIME_RENDER_OFFLOAD" = "1";
    #"__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
    "__VK_LAYER_NV_optimus" = "NVIDIA_only";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    mpv
    iwgtk
    feh
    inkscape
    gimp
    tdesktop
    obsidian

    libva-utils

    wayvnc
    sunshine
  ];
}
