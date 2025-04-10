{
  description = "Grazor nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    nix-darwin,
    nixpkgs,
    ...
  }: let
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    allSystems = [linuxSystem darwinSystem];
    inherit (nixpkgs) lib;
  in {
    nixosConfigurations = {
      "minisrv" = let
        system = linuxSystem;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = import ./hosts/minisrv/modules.nix (inputs // {inherit system pkgs lib;});
        };

      "dell" = let
        system = linuxSystem;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs;};
          modules = import ./hosts/dell/modules.nix (inputs // {inherit system pkgs lib;});
          # modules = [
          #   ./modules
          #   ./modules/linux
          #   ./hosts/dell
          # ];
        };
    };

    darwinConfigurations."MSK-GRVQ3CV9RQ" = nix-darwin.lib.darwinSystem {
      system = darwinSystem;
      specialArgs = {inherit inputs;};
      modules = [
        ./modules
        ./hosts/darwin
        inputs.home-manager.darwinModules.home-manager
      ];
    };

    devShells = import ./shells {inherit allSystems nixpkgs;};
  };
}
