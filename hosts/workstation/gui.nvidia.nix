{ pkgs, config, ... }:

let
  sunshineWithCuda = pkgs.sunshine.override { cudaSupport = true; };

  #revision from https://github.com/keylase/nvidia-patch to use
  rev = "cb0136eab688ffa44c217218f31fe2149477ada3";
  hash = "sha256-awwk9W06Pq7zoWt1FYZGEQXNYUP6Rr1iocCu1KTgsM4=";

  # create patch functions for the specified revision
  nvidia-patch = pkgs.nvidia-patch rev hash;

  nvidiaPackage =
    config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs rec {
      version = "550.54.14";
      src = builtins.fetchurl {
        url =
          "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
        sha256 = "sha256-jEl/8c/HwxD7h1FJvDD6pP0m0iN7LLps0uiweAFXz+M=";
      };
    };
in {
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      defaultSession = "hyprland";
    };
    libinput.enable = false;
  };

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
    package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc nvidiaPackage);
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

    "__NV_PRIME_RENDER_OFFLOAD" = "1";
    "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
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

    wayvnc
    sunshine
  ];
}
