{ pkgs, lib, ... }:

{
  imports = [ ./nixos ./packages ];

  time.timeZone = "Europe/Moscow";
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    settings.sandbox = true;
    package = pkgs.nixUnstable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "20.03";
}
