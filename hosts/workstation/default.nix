{ lib, ... }:

{
  imports = [
    ./hardware.nix
    ./wireless.nix
    ./gui.nix
    ./work.nix

    ../../shared/homecloud.nix
    ../../shared/arduino.nix
    ../../shared/android.nix
    ../../shared/steam.nix
  ];

  programs.nix-ld.enable = true;
  nix.settings.max-jobs = lib.mkDefault 8;
}
