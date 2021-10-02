with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "rustdev";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  hardeningDisable = [ "fortify" ];
  buildInputs = [ gcc cargo rustc rust-analyzer rustfmt ];
}
