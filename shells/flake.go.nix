{ pkgs ? import <nixpkgs> { } }:
with pkgs;

mkShell {
	hardeningDisable = [ "fortify" ];

	buildInputs = [ gcc go_1_20 gopls golangci-lint delve vault universal-ctags ];
	propagatedBuildInputs = [ stdenv.cc.cc.lib ];

	shellHook = ''
		export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
		export PATH=$GOPATH/bin:$PATH
	'';
}
