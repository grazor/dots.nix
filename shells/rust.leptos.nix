{ pkgs }:

with pkgs;

mkShell {
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    cacert

    rust-analyzer
    rustfmt

    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
        targets = [ "wasm32-unknown-unknown" ];
      }))

    cargo
    cargo-watch
    cargo-leptos
    cargo-make

    trunk

    nodejs

    wasm-pack
  ] ++ pkgs.lib.optionals pkg.stdenv.isDarwin
    [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  shellHook = ''
    export PATH=$PATH:$HOME/.cargo/bin
  '';
}
