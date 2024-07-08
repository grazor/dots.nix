{ pkgs, config, ... }:

let
  sunshineWithCuda = pkgs.sunshine.override { cudaSupport = true; };

  #revision from https://github.com/keylase/nvidia-patch to use
  rev = "e416c41eff69dd53b4d98072df68369cf6f34312";
  hash = "sha256-1gbgqWvbf9wfPXyozGuLbma6GsLSclldh7Kn9pznxao=";

  # create patch functions for the specified revision
  nvidia-patch = pkgs.nvidia-patch rev hash;

  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
in
# nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.mkDriver {}
{
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
      defaultSession = "hyprland";
    };
  };

  hardware.uinput.enable = true;

  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    #package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc nvidiaPackage);
    package = nvidiaPackage;

    prime = {
      sync.enable = true;
      #offload.enable = true;
      #offload.enableOffloadCmd = true;
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
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "NVD_BACKEND" = "direct";

    "__NV_PRIME_RENDER_OFFLOAD" = "1";
    "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" = "NVIDIA-G0";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "__VK_LAYER_NV_optimus" = "NVIDIA_only";
  };

  # env = LIBVA_DRIVER_NAME,nvidia
  # env = XDG_SESSION_TYPE,wayland
  # env = GBM_BACKEND,nvidia-drm
  # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  # env = WLR_NO_HARDWARE_CURSORS,1
  #
  # env = __NV_PRIME_RENDER_OFFLOAD,1
  # env = __NV_PRIME_RENDER_OFFLOAD_PROVIDER,NVIDIA-G0
  # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  # env = __VK_LAYER_NV_optimus,NVIDIA_only

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
