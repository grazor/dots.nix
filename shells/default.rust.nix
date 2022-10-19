{ pkgs ? import <nixpkgs> { } }:

let

in pkgs.mkShell rec {
  buildInputs = with pkgs; [
    cargo rustc rust-analyzer rustfmt
  ];
}
