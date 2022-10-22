{ lib, ... }:

{
  imports = [ ./hardware.nix ./users.nix ./services ./network.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
