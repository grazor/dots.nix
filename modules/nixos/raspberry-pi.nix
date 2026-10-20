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
      # Screen only: the PL011 UART (ttyAMA0) is wired to the onboard
      # Bluetooth chip, which hci_uart can only claim with no console on it.
      kernelParams = ["console=tty1"];
    };
  };
}
