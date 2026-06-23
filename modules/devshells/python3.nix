{
  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    py = pkgs.python312Packages;
    hooks = preCommit {
      ruff.enable = true;
      ruff-format.enable = true;
    };
  in {
    devShells.python3 = pkgs.mkShell {
      name = "python3";
      venvDir = "./.venv.py3";
      buildInputs =
        (with py; [
          python
          venvShellHook
          six
          certifi
          requests
          pip
          python-lsp-server
        ])
        ++ (with pkgs; [
          ruff
          taglib
          openssl
          git
          libxml2
          libxslt
          libzip
          zlib
        ])
        ++ hooks.enabledPackages;
      # libstdc++ on PATH for binary wheels — Linux only.
      propagatedBuildInputs = lib.optionals pkgs.stdenv.isLinux [pkgs.stdenv.cc.cc.lib];
      postVenvCreation = ''
        unset SOURCE_DATE_EPOCH
        pip install pdbpp poetry jupyter
      '';
      postShellHook =
        ''
          unset SOURCE_DATE_EPOCH
        ''
        + lib.optionalString pkgs.stdenv.isLinux ''
          export LD_LIBRARY_PATH=${lib.makeLibraryPath [pkgs.stdenv.cc.cc pkgs.libGL]}
        ''
        + hooks.shellHook;
    };
  };
}
