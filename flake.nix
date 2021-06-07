{
  inputs.home-manager = {
    url = "github:rycee/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.neovim-nightly-overlay.url =
    "github:nix-community/neovim-nightly-overlay";

  outputs = { self, nixpkgs, home-manager }:
    with nixpkgs.lib;
    let

      overlays = [ inputs.neovim-nightly-overlay.overlay ];

      mkNixosConfiguration = name:
        { config ? ./hosts + "/${name}" }:
        nameValuePair name (nixosSystem {
          system = "x86_64-linux";
	  overlays = overlays;
          modules = traceVal [
            ./configuration.nix
            (import config)
            ({ ... }: { networking.hostName = name; })
          ];
        });

    in {
      nixosConfigurations = mapAttrs' mkNixosConfiguration { pozon = { }; };
    };
}
