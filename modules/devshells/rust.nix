{
  perSystem = {pkgs, ...}: {
    devShells.rust = pkgs.mkShell {
      name = "rust";
      nativeBuildInputs = [pkgs.pkg-config];
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
  };
}
