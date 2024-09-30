{
  pkgs ? import <nixpkgs> { },
  pythonPackages ? pkgs.python312Packages,
  version ? "3.12",
}:

pkgs.mkShell {
  name = "py-" + version;
  venvDir = "./.venv." + version;

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
