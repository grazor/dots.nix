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
          modules = import ./hosts/dell/modules.nix (inputs // {inherit system pkgs lib;});
        };
    };

    darwinConfigurations."MSK-GRVQ3CV9RQ" = let
      system = darwinSystem;
      pkgs = nixpkgs.legacyPackages.${darwinSystem};
      inherit (nix-darwin) lib;
    in
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = import ./hosts/darwin/modules.nix (inputs // {inherit system pkgs lib;});
      };

    devShells = import ./shells {inherit allSystems nixpkgs;};
  };
}
