with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "ozon";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  buildInputs = [ gcc go_1_15 golangci-lint protobuf kafkacat delve grpcurl mockgen vault ];
  hardeningDisable = [ "fortify" ];

  GOPATH = "/home/g/go:/home/g/Ozon:/home/g/Projects";
  GONOPROXY = "";
  GONOSUMDB = "*.ozon.ru";
  GOPRIVATE = "";
  GOPROXY = "https://athens.s.o3.ru";
  GOSUMDB = "sum.golang.org";
  WARDEN_HOST = "warden.platform.stg.s.o3.ru:82";
}
