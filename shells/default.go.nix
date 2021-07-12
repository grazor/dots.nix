with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "godev";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  hardeningDisable = [ "fortify" ];
  buildInputs = [ gcc go golangci-lint protobuf delve grpcurl mockgen ];

  GOPATH = "/home/g/go:/home/g/Projects";
}
