{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./postgresql.nix ];

  nix.maxJobs = lib.mkDefault 8;
}
