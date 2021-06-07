{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ];

  nix.maxJobs = lib.mkDefault 8;
}
