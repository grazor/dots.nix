with import <nixpkgs> { };

let pythonPackages = python311Packages;
in stdenv.mkDerivation rec {
  name = "dev-python";

  venvDir = ".venv";

  buildInputs = [
    pythonPackages.python
    pythonPackages.venvShellHook

    openssl
    git
    libxml2
    libxslt
    libzip
    zlib
    cmake
  ];

  propagatedBuildInputs = [ pythonPackages.setuptools pythonPackages.six ];

  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
  '';

  postShellHook = ''
    unset SOURCE_DATE_EPOCH

    pip install pdbpp poetry
  '';

}
