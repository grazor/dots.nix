{
  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system} = {
        go = import ./flake.go.nix { inherit pkgs; };
        python8 = import ./flake.python8.nix { inherit pkgs; };
        python10 = import ./flake.python10.nix { inherit pkgs; };
        python11 = import ./flake.python11.nix { inherit pkgs; };
        python12 = import ./flake.python12.nix { inherit pkgs; };
        rustwasm = import ./flake.rustwasm.nix { inherit pkgs; };
        js = import ./flake.js.nix { inherit pkgs; };
      };
    };
}

