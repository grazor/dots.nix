{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ];

  nix.maxJobs = lib.mkDefault 8;
}