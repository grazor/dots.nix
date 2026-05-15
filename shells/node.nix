{pkgs, ...}:
pkgs.mkShell {
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

  propagatedBuildInputs = with pkgs; [stdenv.cc.cc.lib];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
  '';
}
