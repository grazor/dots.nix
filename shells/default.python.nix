with import <nixpkgs> { };

let
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
    # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
    unset SOURCE_DATE_EPOCH
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
  '';
}

