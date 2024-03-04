{ pkgs, gopkgs, gopkg, toolchain, version }:

with pkgs;
mkShell {
  name = "go-" + version;
  hardeningDisable = [ "fortify" ];

  buildInputs = [
    gcc
    gopkg
    gopkgs.gopls
    gopkgs.golines
    gopkgs.gotools
    gopkgs.golangci-lint
    delve
    vault
    universal-ctags
  ];
  propagatedBuildInputs = [ stdenv.cc.cc.lib ];

  GOPATH = "/home/g/go";
  GOTOOLCHAIN = toolchain;

  shellHook = ''
    #export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib/\"
    export PATH=$GOPATH/bin:$PATH
  '';
}
