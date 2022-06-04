{ lib, ... }:

{
  imports = [ ./hardware.nix ./services.nix ./gui.nix ./users.nix ./services ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
