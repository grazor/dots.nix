# Shared pre-commit wiring for the language dev shells.
#
# Each shell calls `preCommit { <hook>.enable = true; … }` and folds the result
# into its own `buildInputs` (via `.enabledPackages`) and `shellHook` (via
# `.shellHook`). Entering the shell then installs a `.git/hooks/pre-commit` in
# the *consuming* repo and writes a `.pre-commit-config.yaml` that points at the
# nix-built formatters — both are gitignored and torn down by `bin/project`.
#
# alejandra is enabled everywhere, so nix files in any project stay formatted to
# match this repo's style (same formatter as `nix fmt` / treefmt here).
#
# Combo shells (`project use rust+node`) install the *union* of their parts'
# hooks, because git-hooks.nix owns `.pre-commit-config.yaml` exclusively: its
# installer unlinks any symlink that is not its own config, so with two
# installers only the last one's hooks would survive. Hence:
#
#   * the per-shell installer is wrapped in a `$PROJECT_COMBO_HOOKS` guard, which
#     the generated combo shell sets as a derivation env attr — those are
#     exported by `nix print-dev-env` before any shellHook runs, so every part
#     stands down;
#   * each hook set is published as `flake.devshellHooks.<shell>` (plain data, no
#     `pkgs`), which is what the combo unions;
#   * `flake.lib.devshellHooks` is the unguarded builder the combo hands that
#     union to.
{
  inputs,
  lib,
  ...
}: let
  mkHooks = system: hooks:
    inputs.git-hooks.lib.${system}.run {
      # `src` only feeds the (unused) CI check derivation; the shellHook
      # installs against $PWD, so this just has to be a valid path.
      src = ./.;
      hooks = {alejandra.enable = true;} // hooks;
    };

  # Stand down when a combo shell owns installation (see the header).
  guard = run:
    run
    // {
      shellHook = ''
        if [ -z "''${PROJECT_COMBO_HOOKS-}" ]; then
        ${run.shellHook}
        fi
      '';
    };
in {
  # Declared (rather than left to the freeform `flake.*`) so each language module
  # can contribute its own key — freeform outputs are unique-per-output and
  # would refuse to merge across modules.
  options.flake.devshellHooks = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.attrsOf lib.types.raw);
    default = {};
    description = ''
      Pre-commit hook config per devShell, as plain data, for `bin/project` to
      union when it generates a combo shell. Keys are matched as *prefixes* of a
      shell name, so `avito.go` covers every `avito.go.<version>`.
    '';
  };

  # `options` above forces the rest of this module under an explicit `config`.
  config = {
    flake-file.inputs.git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unguarded on purpose: the combo shell is the installer of last resort.
    flake.lib.devshellHooks = mkHooks;

    perSystem = {system, ...}: {
      _module.args.preCommit = hooks: guard (mkHooks system hooks);
    };
  };
}
