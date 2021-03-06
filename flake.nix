{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.home-manager = {
    url = "github:rycee/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    with nixpkgs.lib;
    let

      overlays = [ inputs.neovim-nightly-overlay.overlay ];

      mkNixosConfiguration = name:
        { config ? ./hosts + "/${name}", users ? [ "g" ] }:
        nameValuePair name (nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            (import config)
            ({ ... }: { networking.hostName = name; })
            { nixpkgs.overlays = overlays; }
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
        pzb = { users = [ "cloud" ]; };
        pozon = { };
        pdsk = { };
        pdell = { };
      };
    };
}
