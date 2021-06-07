{
  inputs.home-manager = {
    url = "github:rycee/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }:
    with nixpkgs.lib;
    let
      mkNixosConfiguration = name:
        { config ? ./hosts + "/${name}" }:
        nameValuePair name (nixosSystem {
          system = "x86_64-linux";
          modules = traceVal [
            ./configuration.nix
            ./hosts/pozon
            ({ ... }: { networking.hostName = name; })
          ];
        });

    in {
      nixosConfigurations = mapAttrs' mkNixosConfiguration { pozon = { }; };
    };
}
