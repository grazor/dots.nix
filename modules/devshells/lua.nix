let
  # Published as data too, so combo shells can union it (see hooks.nix).
  hookConfig = {stylua.enable = true;};
in {
  flake.devshellHooks.lua = hookConfig;

  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    hooks = preCommit hookConfig;
  in {
    devShells.lua = pkgs.mkShell {
      name = "lua";
      buildInputs =
        (with pkgs; [
          autoconf
          automake
          gcc
          gnumake
          libiconv
          makeWrapper
          pkg-config
          lua-language-server
          stylua
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
