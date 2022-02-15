let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "rustdev";
    buildInputs = [
      gcc openssl
      rust-analyzer
      #nixpkgs.latest.rustChannels.nightly.rust
      (nixpkgs.rustChannelOf { date = "2021-08-09"; channel = "nightly"; }).rust
    ];
  }

