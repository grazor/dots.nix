{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.home-manager = {
    url = "github:rycee/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  #inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  inputs.nix-alien.url = "github:thiagokokada/nix-alien";

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    with nixpkgs.lib;
    let
      #overlays = [ inputs.neovim-nightly-overlay.overlay ];
	  #overlays = [ inputs.nix-alien.overlays.default ];
	  overlays = [ ];
	  system = "x86_64-linux";
	  alien = self.inputs.nix-alien.packages.${system};

      mkNixosConfiguration = name:
        { config ? ./hosts + "/${name}", users ? [ "g" ] }:
        nameValuePair name (nixosSystem {
		  system = system;
          modules = [
            ./configuration.nix
            (import config)
            ({ ... }: { networking.hostName = name; })
            { nixpkgs.overlays = overlays; }
			#({ pkgs, ... }: { environment.systemPackages = with pkgs; [ nix-alien ]; })
			({...}: {environment.systemPackages = with alien; [ nix-alien ]; })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = listToAttrs (map (x: {
                name = x;
                value = import (./. + "/home/${x}");
              }) users);
            }
          ];
        });

    in {
      nixosConfigurations = mapAttrs' mkNixosConfiguration {
        desktop = { };
        workstation = { };
        minisrv = { users = [ "cloud" ]; };
        server = { users = [ "cloud" ]; };
      };
    };
}
