# Proprietary NVIDIA driver (desktop GPU: GTX 1070, Pascal).
{
  flake.modules.nixos.graphics-nvidia = {config, ...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # hardware.nvidia.videoAcceleration installs nvidia-vaapi-driver (VAAPI
    # over NVDEC); point libva at it for hardware decode in Firefox/Zen.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      # Saves VRAM across suspend; without it GNOME Wayland resumes to a
      # black or corrupted screen.
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      # The open kernel modules need Turing or newer.
      open = false;
      nvidiaSettings = true;
      # Pascal was dropped after the 580 branch; production/latest ignore the card.
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
  };
}
