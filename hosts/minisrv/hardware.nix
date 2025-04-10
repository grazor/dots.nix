{lib, ...}: {
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/113b48ee-0900-41d6-96c6-282339186a45";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/813A-20C2";
      fsType = "vfat";
      options = ["rw" "relatime" "fmask=0022"];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/ef3748a4-2df3-46ae-8bed-bef4fb71176a";
      fsType = "ext4";
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/422855ea-f017-47c5-beef-4b7e14fae92e";}];

  hardware.bluetooth.enable = true;
  services.logind.lidSwitch = "ignore";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
