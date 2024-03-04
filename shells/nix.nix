{ pkgs ? import <nixpkgs> { } }:
with pkgs;

mkShell {
  buildInputs = [
    autoconf
    automake
    bison
    flex
    fontforge
    gcc
    gnumake
    libiconv
    libtool
    makeWrapper
    pkg-config

    nixd
    nixfmt
  ];

  propagatedBuildInputs = [ stdenv.cc.cc.lib ];

  shellHook =
    "	export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/\n	export PATH=$GOPATH/bin:$PATH\n";
}
