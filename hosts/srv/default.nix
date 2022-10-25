{ lib, ... }:

{
  imports = [ ./hardware.nix ./users.nix ./services ./network.nix ./smb.nix ./zfs.nix ./k8s.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
