{ lib, ... }:

{
  imports = [
    ./hardware.nix
    ./nvidia.nix
    ./gui.nix

    ../../shared/steam.nix
    ../../shared/homecloud.nix
    ../../shared/arduino.nix
  ];

  nix.settings.max-jobs = lib.mkDefault 8;
}
