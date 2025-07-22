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
    linuxAarchSystem = "aarch64-linux";
    darwinSystem = "aarch64-darwin";
    allSystems = [linuxSystem linuxAarchSystem darwinSystem];

    commonModules = [
      inputs.nvf.nixosModules.default
      ./modules
      ./modules/overlay.nix
    ];

    linuxModules =
      commonModules
      ++ [
        inputs.home-manager.nixosModules.home-manager
        ./modules/linux
        ./modules/services
      ];

    darwinModules =
      commonModules
      ++ [
        inputs.home-manager.darwinModules.home-manager
        ./modules/darwin
        ./hosts/darwin.nix
      ];

    specialArgs = {inherit inputs;};
  in {
    nixosConfigurations = {
      "minisrv" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = linuxSystem;
        modules = linuxModules ++ [./hosts/minisrv];
      };

      "dell" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = linuxSystem;
        modules = linuxModules ++ [./hosts/dell];
      };

      "desktop" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = linuxSystem;
        modules = linuxModules ++ [./hosts/desktop];
      };

      "hl-rpi-mqtt" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = linuxAarchSystem;
        modules = linuxModules ++ [./hosts/hl-rpi-mqtt];
      };
    };

    darwinConfigurations."MSK-GRVQ3CV9RQ" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      system = darwinSystem;
      modules = darwinModules;
    };

    devShells = import ./shells {inherit allSystems nixpkgs;};
  };
}
