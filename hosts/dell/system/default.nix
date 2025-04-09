inputs @ {lib, ...}: {
  imports = [
    ./hardware.nix
    ./nvidia.nix

    (import ../../_common/system/nix.nix inputs)
    ../../_common/system/devtools.nix
    ../../_common/system/devtools.nix
    ../../_common/system/docker.nix
    ../../_common/system/linux.nix
    ../../_common/system/pipewire.nix
    ../../_common/system/tools.nix
    ../../_common/system/udev.nix
    ../../_common/system/wireless.nix
  ];

  services.logrotate.checkConfig = false;

  nix.settings.max-jobs = lib.mkDefault 8;
  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
