{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let pythonPackages = pkgs.python310Packages;

in mkShell {
  name = "py310";
  venvDir = "./.venv.10";
  buildInputs = with pkgs; [
    pythonPackages.python
    pythonPackages.venvShellHook
    pythonPackages.six
    pythonPackages.certifi

    ruff
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

  postVenvCreation = "	unset SOURCE_DATE_EPOCH\n	pip install pdbpp poetry\n";

  postShellHook =
    "	unset SOURCE_DATE_EPOCH\n	export LD_LIBRARY_PATH=\"${pkgs.stdenv.cc.cc.lib}/lib\"\n";
}

