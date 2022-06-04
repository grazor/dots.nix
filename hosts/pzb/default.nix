{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./users.nix ./services ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
