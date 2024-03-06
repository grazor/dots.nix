{ pkgs, pythonPackages, version }:

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
  '';
}
