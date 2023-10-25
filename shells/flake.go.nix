{
  description = "wasm-pack setup";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = { nixpkgs, ... }:
    let system = "x86_64-linux";
    in {
      devShell.${system} = let
        pkgs = import nixpkgs {
          inherit system;
        };
      in (({ pkgs, ... }:
        pkgs.mkShell {
		hardeningDisable = [ "fortify" ];

		buildInputs = with pkgs; [ gcc go_1_20 gopls golangci-lint delve vault universal-ctags ];
		propagatedBuildInputs = with pkgs; [ stdenv.cc.cc.lib ];

		shellHook = ''
			export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
			export PATH=$GOPATH/bin:$PATH
		'';
        }) { pkgs = pkgs; });
    };
}
