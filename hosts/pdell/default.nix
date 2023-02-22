{ lib, ... }:

{
  imports = [
	./hardware.nix
	./gui.nix
	#./psql.nix
	./arduino.nix
	#./steam.nix
	./required.nix
	./dev.nix
	./users.nix
	./smb.nix
  ];

  programs.nix-ld.enable = true;

  nix.settings.max-jobs = lib.mkDefault 8;
}
