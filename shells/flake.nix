{
  outputs = { self, nixpkgs, ... }:
    let
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; };
	in
    {
		devShells.${system} = {
			go = import ./flake.go.nix { inherit pkgs; };
		};
	};
}

