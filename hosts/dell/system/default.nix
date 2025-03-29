inputs @ {lib, ...}: {
  imports = [
    ./hardware.nix

    (import ../../_common/system/nix.nix inputs)
    ../../_common/system/tools.nix
    ../../_common/system/linux.nix
    ../../_common/system/docker.nix
    ../../_common/system/wireless.nix
    ../../_common/system/pipewire.nix
    ../../_common/system/udev.nix
  ];

  services.logrotate.checkConfig = false;

  nix.settings.max-jobs = lib.mkDefault 8;
  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
