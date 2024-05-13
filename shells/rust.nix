{ pkgs }:

with pkgs;

mkShell {
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    cacert

    rust-analyzer
    rustfmt
    rustc
    rr

    cargo
    cargo-watch
    cargo-make
    cargo-generate

    protobuf
  ];

  shellHook = ''
    export PATH=$PATH:$HOME/.cargo/bin

    export PROTOBUF_LOCATION=${protobuf}
    export PROTOC=$PROTOBUF_LOCATION/bin/protoc
    export PROTOC_INCLUDE=$PROTOBUF_LOCATION/include
  '';
}
