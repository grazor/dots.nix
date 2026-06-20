# Wi-Fi via iwd backed by NetworkManager.
{
  flake.modules.nixos.wireless = {pkgs, ...}: {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    environment.systemPackages = [pkgs.wirelesstools];
  };
}
