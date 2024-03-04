{ pkgs ? import <nixpkgs> { } }:

let
  rustOverlay = builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
  };
  nixpkgs = pkgs.appendOverlays [ (import rustOverlay) ];

in with pkgs;

mkShell {
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    cargo
    cargo-watch
    nodejs
    wasm-pack
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" ];
        targets = [ "wasm32-unknown-unknown" ];
      }))
    rust-analyzer
    rustfmt
  ];

  shellHook = ''
    PATH=$PATH:$HOME/.cargo/bin
  '';
}
