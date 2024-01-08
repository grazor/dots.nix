{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let
	pythonPackages = pkgs.python312Packages;
in

mkShell {
	name = "py312";
	venvDir = "./.venv.12";
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
	'';
}

