{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
        { config ? ./hosts + "/${name}" }:
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
              home-manager.users.g = import ./home/g;
            }
          ];
        });

    in {
      nixosConfigurations = mapAttrs' mkNixosConfiguration {
        pzb = { };
        pozon = { };
        pdesktop = { };
      };
    };
}
