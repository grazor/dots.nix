{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/sda5";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
      options = [ "rw" "relatime" "fmask=0022" ];
    };
    "/home" = {
      device = "/dev/sda6";
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/422855ea-f017-47c5-beef-4b7e14fae92e"; }];

  hardware.bluetooth.enable = true;
  services.logind.lidSwitch = "ignore";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
