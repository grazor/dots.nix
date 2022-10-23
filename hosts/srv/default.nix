{ lib, ... }:

{
  imports = [ ./hardware.nix ./users.nix ./services ./network.nix ./smb.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
