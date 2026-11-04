let
  hookConfig = {gofmt.enable = true;};
in {
  flake.devshellHooks.go = hookConfig;

  perSystem = {
    pkgs,
    preCommit,
    ...
  }: let
    hooks = preCommit hookConfig;
  in {
    devShells.go = pkgs.mkShell {
      name = "go";
      packages = with pkgs; [go gopls];
      nativeBuildInputs = hooks.enabledPackages;
      GOTOOLCHAIN = "local";
      inherit (hooks) shellHook;
    };
  };
}
