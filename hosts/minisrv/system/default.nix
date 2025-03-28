{lib, ...}: {
  imports = [
    ./hardware.nix

    ../../_common/system/nix.nix
    ../../_common/system/tools.nix
    ../../_common/system/linux.nix
    ../../_common/system/docker.nix
    ../../_common/system/wireless.nix
    ../../_common/system/pipewire.nix
    ../../_common/system/udev.nix
  ];

  nix.settings.max-jobs = lib.mkDefault 4;
  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
