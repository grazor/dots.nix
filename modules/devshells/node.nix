let
  # Published as data too, so combo shells can union it (see hooks.nix).
  hookConfig = {prettier.enable = true;};
in {
  flake.devshellHooks.node = hookConfig;

  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    hooks = preCommit hookConfig;
  in {
    devShells.node = pkgs.mkShell {
      name = "node";
      buildInputs =
        (with pkgs; [
          autoconf
          automake
          gcc
          gnumake
          makeWrapper
          pkg-config
          nodejs
        ])
        ++ hooks.enabledPackages;
      propagatedBuildInputs = lib.optionals pkgs.stdenv.isLinux [pkgs.stdenv.cc.cc.lib];
      shellHook =
        lib.optionalString pkgs.stdenv.isLinux ''
          export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
        ''
        + hooks.shellHook;
    };
  };
}
