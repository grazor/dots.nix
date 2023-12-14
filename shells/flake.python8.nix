{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
	pythonPackages = pkgs.python38Packages;
in

mkShell {
	name = "py38";
	venvDir = "./.venv.8";
	buildInputs = with pkgs; [
		pythonPackages.python
		pythonPackages.venvShellHook
		pythonPackages.six
		pythonPackages.certifi

		pythonPackages.pip

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
	'';
}

