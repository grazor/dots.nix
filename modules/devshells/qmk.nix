{
  perSystem = {
    pkgs,
    lib,
    preCommit,
    ...
  }: let
    # alejandra only — no clang-format, to avoid reformatting vendored QMK
    # firmware C that lives alongside a keymap.
    hooks = preCommit {};
  in {
    devShells.qmk = pkgs.mkShell {
      name = "qmk";
      buildInputs =
        (with pkgs; [
          autoconf
          automake
          gcc
          gnumake
          makeWrapper
          pkg-config
          qmk
          dos2unix
        ])
        ++ hooks.enabledPackages;
      propagatedBuildInputs = lib.optionals pkgs.stdenv.isLinux [pkgs.stdenv.cc.cc.lib];
      shellHook =
        ''
          export CONVERT_TO=promicro_rp2040
        ''
        + lib.optionalString pkgs.stdenv.isLinux ''
          export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
        ''
        + hooks.shellHook;
    };
  };
}
