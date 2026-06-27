# Raspberry Pi board defaults. Intended for Raspberry Pi 4B on a normal
# aarch64 NixOS SD-card style install using U-Boot/extlinux.
{
  flake.modules.nixos.raspberry-pi-4 = {lib, ...}: {
    boot = {
      loader = {
        grub.enable = lib.mkForce false;
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
        generic-extlinux-compatible.enable = true;
      };
      kernelParams = [
        "console=tty1"
        "console=ttyAMA0,115200n8"
      ];
    };
  };
}
