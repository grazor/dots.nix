{pkgs, ...}:
pkgs.mkShell {
  name = "lua";
  buildInputs = with pkgs; [
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
  ];

  propagatedBuildInputs = with pkgs; [stdenv.cc.cc.lib];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
    export PATH="''$GOPATH/bin:''$PATH"
  '';
}
