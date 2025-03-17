{pkgs, ...}:
pkgs.mkShell {
  name = "python3";
  venvDir = "./.venv.py3";

  buildInputs = with pkgs; [
    pythonPackages.python
    pythonPackages.venvShellHook
    pythonPackages.six
    pythonPackages.certifi
    pythonPackages.requests
    pythonPackages.pip
    pythonPackages.python-lsp-server

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

  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install pdbpp poetry jupyter
  '';

  postShellHook = ''
    unset SOURCE_DATE_EPOCH
    export LD_LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.libGL
      ]
    }
  '';
}
