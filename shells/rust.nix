{pkgs, ...}:
pkgs.mkShell {
  name = "rust";
  nativeBuildInputs = with pkgs; [pkg-config];

  buildInputs = with pkgs; [
    openssl
    cacert

    rust-analyzer
    rustfmt
    rustc

    cargo
    cargo-watch
    cargo-make
    cargo-generate
    clippy

    protobuf
  ];

  shellHook = ''
    export PATH=$PATH:$HOME/.cargo/bin

    export PROTOBUF_LOCATION=${pkgs.protobuf}
    export PROTOC=$PROTOBUF_LOCATION/bin/protoc
    export PROTOC_INCLUDE=$PROTOBUF_LOCATION/include
  '';
}
