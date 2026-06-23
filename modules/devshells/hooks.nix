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
{inputs, ...}: {
  flake-file.inputs.git-hooks = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem = {system, ...}: {
    _module.args.preCommit = hooks:
      inputs.git-hooks.lib.${system}.run {
        # `src` only feeds the (unused) CI check derivation; the shellHook
        # installs against $PWD, so this just has to be a valid path.
        src = ./.;
        hooks = {alejandra.enable = true;} // hooks;
      };
  };
}
