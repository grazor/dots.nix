{
  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    hooks = preCommit {stylua.enable = true;};
  in {
    devShells.lua = pkgs.mkShell {
      name = "lua";
      buildInputs =
        (with pkgs; [
          autoconf
          automake
          bison
          flex
          fontforge
          gcc
          gnumake
          libiconv
          libtool
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
