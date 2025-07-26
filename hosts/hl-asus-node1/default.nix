{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./config.nix
  ];

  networking.hostName = "hl-asus-node1";
  networking.firewall.enable = false;
  networking.wireless.iwd.enable = false;
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  environment.systemPackages = [pkgs.wirelesstools];

  system.stateVersion = "25.05";
  nix.settings.max-jobs = lib.mkDefault 4;

  environment.enableAllTerminfo = true;
  services.logrotate.checkConfig = false;

  services.resolved.enable = lib.mkForce false;
}
