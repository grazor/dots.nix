{ pkgs ? import <nixpkgs> { } }:
with pkgs;

mkShell {
  hardeningDisable = [ "fortify" ];

  buildInputs = [ gcc go_1_21 gopls golangci-lint delve vault universal-ctags ];
  propagatedBuildInputs = [ stdenv.cc.cc.lib ];

  shellHook =
    "	export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/\n	export PATH=$GOPATH/bin:$PATH\n";
}
