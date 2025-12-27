{
  allSystems,
  nixpkgs,
  ...
}: let
  forAllSystems = function:
    nixpkgs.lib.genAttrs allSystems (system: function nixpkgs.legacyPackages.${system});
in
  forAllSystems (pkgs: {
    rust = import ./rust.nix {inherit pkgs;};
    lua = import ./lua.nix {inherit pkgs;};
    python3 = import ./python3.nix {inherit pkgs;};
    qmk = import ./qmk.nix {inherit pkgs;};
  })
