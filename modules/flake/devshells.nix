{
  perSystem = {pkgs, ...}: {
    devShells = {
      rust = pkgs.mkShell {
        name = "rust";
        nativeBuildInputs = with pkgs; [pkg-config];
        buildInputs = with pkgs; [
          openssl
          cacert
          rustup
          rust-analyzer
          rustfmt
          tokio-console
          websocat
          protobuf
        ];
        shellHook = ''
          export PATH=$PATH:$HOME/.cargo/bin
          export PROTOBUF_LOCATION=${pkgs.protobuf}
          export PROTOC=$PROTOBUF_LOCATION/bin/protoc
          export PROTOC_INCLUDE=$PROTOBUF_LOCATION/include
        '';
      };

      python3 = let
        pythonPackages = pkgs.python312Packages;
      in
        pkgs.mkShell {
          name = "python3";
          venvDir = "./.venv.py3";
          buildInputs = with pkgs; [
            pythonPackages.python
            pythonPackages.venvShellHook
            pythonPackages.six
            pythonPackages.certifi
            pythonPackages.requests
            pythonPackages.pip
            pythonPackages.python-lsp-server
            ruff
            taglib
            openssl
            git
            libxml2
            libxslt
            libzip
            zlib
          ];
          propagatedBuildInputs = with pkgs; [stdenv.cc.cc.lib];
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install pdbpp poetry jupyter
          '';
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc pkgs.libGL]}
          '';
        };

      node = pkgs.mkShell {
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
      };

      lua = pkgs.mkShell {
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
        '';
      };

      qmk = pkgs.mkShell {
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
          export CONVERT_TO=promicro_rp2040
        '';
      };
    };
  };
}
