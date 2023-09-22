with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "godev";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  hardeningDisable = [ "fortify" ];
  buildInputs = [ gcc go golangci-lint delve gopls protobuf protoc-gen-go protoc-gen-go-grpc universal-ctags shfmt ];

  GOPATH = "/home/g/go:/home/g/Projects";

  shellHook = ''
    go install github.com/segmentio/golines
  '';
}
