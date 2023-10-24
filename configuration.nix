{ pkgs, lib, ... }:

{
  imports = [ ./common ./devshell ];

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

  system.stateVersion = "22.11";
}
