{pkgs, ...}:
pkgs.mkShell {
  name = "qmk";
  buildInputs = with pkgs; [
    autoconf
    automake
    gcc
    gnumake
    makeWrapper
    pkg-config

    qmk
    dos2unix
  ];

  propagatedBuildInputs = with pkgs; [stdenv.cc.cc.lib];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
  '';
}
