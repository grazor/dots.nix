{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/65b0d516-76fe-4a82-bd43-ab937680d82b";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-8da9eb70-9a52-4935-82ca-69d39e465873".device = "/dev/disk/by-uuid/8da9eb70-9a52-4935-82ca-69d39e465873";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A2D3-9A85";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  hardware.bluetooth.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
