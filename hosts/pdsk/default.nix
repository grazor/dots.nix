{ lib, ... }:

{
  imports = [ ./hardware.nix ./nvidia.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ];

  nix.maxJobs = lib.mkDefault 4;
}
