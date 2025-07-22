{lib, ...}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
   system.copySystemConfiguration = true;

  networking.hostName = "hl-rpi-mqtt";
  system.stateVersion = "25.05";

  nix.settings.max-jobs = lib.mkDefault 8;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  networking.firewall.enable = false;
  services.resolved.enable = lib.mkForce false;
}
