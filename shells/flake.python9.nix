{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
	pythonPackages = pkgs.python39Packages;
in

mkShell {
	name = "py39";
	venvDir = "./.venv.9";
	buildInputs = with pkgs; [
		pythonPackages.python
		pythonPackages.venvShellHook
		pythonPackages.six
		pythonPackages.certifi

		taglib
		openssl
		git
		libxml2
		libxslt
		libzip
		zlib
	];

	propagatedBuildInputs = with pkgs; [
		pythonPackages.setuptools
		pythonPackages.six
		stdenv.cc.cc.lib
	];

	postVenvCreation = ''
		unset SOURCE_DATE_EPOCH
		pip install pdbpp poetry
	'';

	postShellHook = ''
		unset SOURCE_DATE_EPOCH
		export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
	'';
}



