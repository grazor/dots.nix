{ pkgs, lib, ... }:

{
  imports = [ ./nixos ./packages ];

  time.timeZone = "Europe/Moscow";
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    settings.sandbox = true;
    package = pkgs.nixUnstable;
  };

  system.stateVersion = "20.03";
}
