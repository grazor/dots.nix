{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:rycee/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # devshells
    go21.url = "nixpkgs/10b813040df67c4039086db0f6eaf65c536886c6";
    go22.url = "nixpkgs/10b813040df67c4039086db0f6eaf65c536886c6";
    rust-overlay.url = "github:oxalica/rust-overlay";

    k3s.url = "nixpkgs/fcb54ddcc974cff59bdfb7c1ac9e080299763d2d";
  };

  nixConfig = {
    tarball-ttl = 2592000;
    warn-dirty = false;
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    nvf,
    home-manager,
    go21,
    go22,
    rust-overlay,
    ...
  } @ inputs:
    with nixpkgs.lib; let
      overlays = [
        inputs.nix-alien.overlays.default
        # inputs.nvidia-patch.overlay
        (import ./overlays)
      ];
      system = "aarch64-darwin";
      alien = self.inputs.nix-alien.packages.${system};
      pkgs = import nixpkgs {inherit system;};

      mkNixosConfiguration = name: {
        config ? ./hosts + "/${name}",
        users ? ["g"],
      }:
        nameValuePair name (nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            (import config)
            (_: {networking.hostName = name;})
            {nixpkgs.overlays = overlays;}
            {environment.systemPackages = [(import ./nvf.nix {inherit pkgs nvf;})];}

            # nix-alien
            (
              {...}: {
                environment.systemPackages = with self.inputs.nix-alien.packages.${system}; [nix-alien];
                programs.nix-ld.enable = true;
              }
            )

            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = listToAttrs (
                map (x: {
                  name = x;
                  value = import (./. + "/home/${x}");
                })
                users
              );
            }
          ];
        });

      minorVersion = v: with builtins; head (match "([[:digit:]]\\.[[:digit:]]+).*" v);

      pythonShells = with builtins;
        listToAttrs (
          map
          (
            p: let
              v = minorVersion p.python.version;
            in {
              name = "python." + v;
              value = (
                import ./shells/python.nix {
                  inherit pkgs;
                  version = v;
                  pythonPackages = p;
                }
              );
            }
          )
          [
            pkgs.python39Packages
            pkgs.python310Packages
            pkgs.python311Packages
            pkgs.python312Packages
          ]
        );

      goShells = with builtins;
        listToAttrs (
          map
          (
            p: let
              gopkgs = p.p;
              gopkg = p.go;
              toolchain = "go" + gopkg.version;
              version = minorVersion gopkg.version;
            in {
              name = "go." + version;
              value = (
                import ./shells/go.nix {
                  inherit
                    pkgs
                    version
                    gopkgs
                    gopkg
                    toolchain
                    ;
                }
              );
            }
          )
          [
            rec {
              p = import go21 {inherit system;};
              go = p.go_1_21;
            }
            rec {
              p = import go22 {inherit system;};
              go = p.go_1_22;
            }
          ]
        );

      rustPkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
    in {
      nixosConfigurations = mapAttrs' mkNixosConfiguration {
        desktop = {};
        workstation = {};
        minisrv = {
          users = ["cloud"];
        };
        server = {
          users = ["cloud"];
        };
      };

      darwinConfigurations."MSK-GRVQ3CV9RQ" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          {nixpkgs.overlays = overlays;}
          {environment.systemPackages = [(import ./nvf.nix {inherit pkgs nvf;})];}
          (import ./hosts/darwin {inherit pkgs;})
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.smporyvaev = import ./home/darwin;
            };
          }
        ];
      };

      devShells.${system} = (
        pythonShells
        // goShells
        // {
          build = import ./shells/build.nix {inherit pkgs;};
          lua = import ./shells/lua.nix {inherit pkgs;};
          nix = import ./shells/nix.nix {inherit pkgs;};
          "rust.leptos" = import ./shells/rust.leptos.nix {pkgs = rustPkgs;};
          rust = import ./shells/rust.nix {inherit pkgs;};
          nodejs18 = import ./shells/nodejs18.nix {inherit pkgs;};
        }
      );
    };
}
