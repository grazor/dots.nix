{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "nvme" "ata_piix" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e4a0f58b-24eb-4c53-9674-d43651f5cb7e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3013-E7A0";
    fsType = "vfat";
  };

  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=6G" "mode=1777" ];
  };

  #fileSystems."/share" = {
  #device = "/dev/disk/by-uuid/89d8f44f-747c-452b-83fe-9559f5d7e8a1";
  #fsType = "ext4";
  #};

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
