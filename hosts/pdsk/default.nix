{ lib, ... }:

{
  imports = [ ./hardware.nix ./nvidia.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
