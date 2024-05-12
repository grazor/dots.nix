{ pkgs }:

with pkgs;

mkShell {
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    cacert

    rust-analyzer
    rustfmt
    rust

    cargo
    cargo-watch
    cargo-make
    cargo-generate

    wasm-pack
  ];

  shellHook = ''
    export PATH=$PATH:$HOME/.cargo/bin
  '';
}
