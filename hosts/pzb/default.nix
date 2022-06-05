{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./users.nix ./services ./network.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
