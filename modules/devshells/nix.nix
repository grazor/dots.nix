{
  perSystem = {
    pkgs,
    preCommit,
    ...
  }: let
    # alejandra comes from preCommit's default; add the nix linters as hooks too.
    hooks = preCommit {
      statix.enable = true;
      deadnix.enable = true;
    };
  in {
    devShells.nix = pkgs.mkShell {
      name = "nix";
      buildInputs =
        (with pkgs; [
          alejandra # formatter (matches `nix fmt` / treefmt here)
          nil # language server (matches the nvf editor config)
          statix # lints / antipatterns
          deadnix # dead-code finder
          nix-output-monitor # nicer `nom build` output
        ])
        ++ hooks.enabledPackages;
      inherit (hooks) shellHook;
    };
  };
}
