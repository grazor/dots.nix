{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
	name = "js";
	buildInputs = with pkgs; [
		npm
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
}
