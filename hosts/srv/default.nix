{ lib, ... }:

{
  imports = [ ./hardware.nix ./users.nix ./services ./network.nix ./smb.nix ./zfs.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
