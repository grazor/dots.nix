{ lib, ... }:

{
  imports = [ ./hardware.nix ./users.nix ./services ./network.nix ./smb.nix ./zfs.nix ./k8s.nix ./nvidia.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
