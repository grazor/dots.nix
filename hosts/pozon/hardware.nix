{ pkgs, lib, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b224675d-090f-4c95-ac65-b2900670601f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2AB9-B0D7";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/b37b2f26-f329-43f5-83f7-ade73bb64caa"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
