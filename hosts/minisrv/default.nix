{ lib, ... }:

{
  imports = [ ./hardware.nix ./services ];

  nix.settings.max-jobs = lib.mkDefault 4;
  networking.firewall.enable = false;
}

