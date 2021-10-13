with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "rustdev";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  nativeBuildInputs = with pkgs; [ rustc cargo gcc openssl pkg-config ];
  buildInputs = [ rust-analyzer rustfmt ];
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
