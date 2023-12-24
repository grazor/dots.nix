{ lib, ... }:

{
  imports = [
    ./hardware.nix
    ./cachix.nix
    ./wireless.nix
    ./gui.nix
    ./hyprland.nix
    ./work.nix

    ../../shared/homecloud.nix
    ../../shared/arduino.nix
    ../../shared/android.nix
    ../../shared/steam.nix
  ];

  programs.nix-ld.enable = true;
  nix.settings.max-jobs = lib.mkDefault 8;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

}
