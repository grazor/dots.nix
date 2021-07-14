{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ./required.nix ];

  nix.maxJobs = lib.mkDefault 8;
}
