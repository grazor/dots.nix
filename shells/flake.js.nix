{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
	name = "js";
	buildInputs = with pkgs; [
		nodejs
		yarn

		taglib
		openssl
		git
		libxml2
		libxslt
		libzip
		zlib
	];

	propagatedBuildInputs = with pkgs; [
		stdenv.cc.cc.lib
	];

    shellHook =
      "	export PATH=node_modules/.bin:$PATH\n";
}
