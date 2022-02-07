{ lib, ... }:

{
  imports = [ ./hardware.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ./required.nix ];

  nix.settings.max-jobs = lib.mkDefault 8;
}
