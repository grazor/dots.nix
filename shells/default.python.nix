with import <nixpkgs> { };

let pythonPackages = python39Packages;
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

  propagatedBuildInputs = [ pythonPackages.setuptools pythonPackages.six ];

  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
  '';

  postShellHook = ''
    unset SOURCE_DATE_EPOCH

    alias pip="python -m pip"
  '';

}
