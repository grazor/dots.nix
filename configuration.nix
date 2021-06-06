{ pkgs, lib, ... }:

with lib;

let
  device = strings.fileContents ./installation;
  hardware = ./. + "/hardware/${device}.nix";
  installation = ./. + "/installations/${device}";

in {
  imports = [
    hardware
    installation

    ./nixos
    ./packages
  ];

  time.timeZone = "Europe/Moscow";
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    useSandbox = true;
    package = pkgs.nixUnstable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "20.03";
}
