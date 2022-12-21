with import <nixpkgs> { };

let
  python = python39;
  pythonPackages = python39Packages;
in stdenv.mkDerivation rec {
  name = "dev-python";

  venvDir = ".venv";

  buildInputs = [
    pythonPackages.python
    pythonPackages.pip
    pythonPackages.poetry

    pythonPackages.requests
    pythonPackages.pynvim

    openssl
    git
    libxml2
    libxslt
    libzip
    zlib
  ];

  propagatedBuildInputs = [
      pythonPackages.setuptools
      pythonPackages.six
      stdenv.cc.cc.lib
  ];

  shellHook = ''
    unset SOURCE_DATE_EPOCH
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${python.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
	export PIP_DISABLE_PIP_VERSION_CHECK=1

	pip install pdbpp
  '';
}


