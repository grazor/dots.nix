{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.node = pkgs.mkShell {
      name = "node";
      buildInputs = with pkgs; [
        autoconf
        automake
        bison
        fontforge
        gcc
        gnumake
        makeWrapper
        pkg-config
        nodejs
      ];
      propagatedBuildInputs = lib.optionals pkgs.stdenv.isLinux [pkgs.stdenv.cc.cc.lib];
      shellHook = lib.optionalString pkgs.stdenv.isLinux ''
        export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
      '';
    };
  };
}
