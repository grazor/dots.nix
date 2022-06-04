{ lib, ... }:

{
  imports = [ ./hardware.nix ./nvidia.nix ./gui.nix ./psql.nix ./arduino.nix ./steam.nix ./dev.nix ./users.nix ];

  nix.settings.max-jobs = lib.mkDefault 4;
}
