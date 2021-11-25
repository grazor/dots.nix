with import <nixpkgs> { };

let
  pythonPackages = python39Packages;
in stdenv.mkDerivation rec {
  name = "dev-python";

  venvDir = ".venv";

  buildInputs = [
    pythonPackages.python
    pythonPackages.venvShellHook

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
  ];

  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
  '';

  postShellHook = ''
    unset SOURCE_DATE_EPOCH
    export PIP_INDEX_URL=http://pypi.k.avito.ru/pypi/
    export PIP_TRUSTED_HOST=pypi.k.avito.ru

    alias pip="python -m pip"
  '';

}
