{pkgs, ...}:
pkgs.mkShell {
  name = "rust";
  nativeBuildInputs = with pkgs; [pkg-config];

  buildInputs = with pkgs; [
    openssl
    cacert

    rust-analyzer
    rustfmt
    cargo-watch
    cargo-make
    cargo-generate
    clippy

    rustup
    cargo-cross
    tokio-console
    websocat

    protobuf
  ];

  shellHook = ''
    export PATH=$PATH:$HOME/.cargo/bin

    export PROTOBUF_LOCATION=${pkgs.protobuf}
    export PROTOC=$PROTOBUF_LOCATION/bin/protoc
    export PROTOC_INCLUDE=$PROTOBUF_LOCATION/include

    # Setup macOS SDK paths for cross-compilation
    export SDKROOT=$(xcrun --show-sdk-path)

    # For x86_64-apple-darwin cross-compilation, use cargo-cross
    # For native compilation, use cargo normally
    echo "Rust targets available for cross-compilation:"
    rustup target list | grep darwin
  '';
}
