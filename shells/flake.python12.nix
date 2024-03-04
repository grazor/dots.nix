{ pkgs ? import <nixpkgs> { } }:
with pkgs;

let pythonPackages = pkgs.python312Packages;

in mkShell {
  name = "py312";
  venvDir = "./.venv.12";
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

