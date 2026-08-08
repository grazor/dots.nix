let
  # Published as data too, so combo shells can union it (see hooks.nix).
  hookConfig = {
    ruff.enable = true;
    ruff-format.enable = true;
  };
in {
  flake.devshellHooks.python3 = hookConfig;

  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    # Track the same interpreter the systems install (`python3` in
    # modules/shared/devtools.nix) instead of pinning a version: one store path
    # shared between the system profile and every venv, nothing extra to fetch.
    py = pkgs.python3Packages;
    hooks = preCommit hookConfig;
  in {
    devShells.python3 = pkgs.mkShell {
      name = "python3";
      venvDir = "./.venv.py3";
      buildInputs =
        # No python-lsp-server here on purpose: it is not in the binary cache for
        # darwin, so it and its check inputs (pylint, isort, pylama, vulture,
        # pint, uncertainties, scipy) got built from source on every entry. The
        # editor brings its own LSP (nvf `languages.python.lsp`); if you want one
        # in the shell too, add `pkgs.basedpyright` — that one is cached.
        (with py; [
          python
          venvShellHook
          six
          certifi
          requests
          pip
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

      # Public PyPI, overriding whatever `PIP_INDEX_URL` the ambient shell has.
      # The corporate mirror is only reachable on VPN, and off it every `pip`
      # call burns 5×15s of connect timeouts before failing — including the one
      # in `postVenvCreation`, which is why this is a derivation env attr and
      # not a shellHook line: those are exported before any hook runs.
      PIP_INDEX_URL = "https://pypi.org/simple";
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
