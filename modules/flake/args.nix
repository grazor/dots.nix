{inputs, ...}: {
  systems = ["x86_64-linux" "aarch64-darwin"];

  # pkgs used by perSystem outputs (devShells). Unfree allowed to match the
  # system configurations.
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
