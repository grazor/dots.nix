{pkgs, ...}: {
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  environment.systemPackages = [pkgs.wirelesstools];
}
