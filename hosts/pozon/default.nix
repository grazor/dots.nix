{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./psql.nix ];

  nix.maxJobs = lib.mkDefault 8;
}
