{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./psql.nix ./arduino.nix ];

  nix.maxJobs = lib.mkDefault 8;
}
