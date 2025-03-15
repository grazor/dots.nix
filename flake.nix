{
  description = "Grazor nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    home-manager,
    nixpkgs,
  }: let
    #system.configurationRevision = self.rev or self.dirtyRev or null;
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    allSystems = [linuxSystem darwinSystem];
  in {
    nixosConfigurations."minisrv" = let
      system = linuxSystem;
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (import ./hosts/darwin/minisrv)
        ];
      };

    darwinConfigurations."MSK-GRVQ3CV9RQ" = let
      system = darwinSystem;
      pkgs = nixpkgs.legacyPackages.${darwinSystem};
    in
      nix-darwin.lib.darwinSystem {
        inherit system;
        modules = import ./hosts/darwin/modules.nix (inputs // {inherit system pkgs;});
      };

    shells = import ./shells {inherit allSystems nixpkgs;};
  };
}
