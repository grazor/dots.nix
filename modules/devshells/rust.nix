let
  # Published as data too, so combo shells can union it (see hooks.nix).
  hookConfig = {rustfmt.enable = true;};
in {
  flake.devshellHooks.rust = hookConfig;

  perSystem = {
    pkgs,
    preCommit,
    ...
  }: let
    hooks = preCommit hookConfig;
  in {
    devShells.rust = pkgs.mkShell {
      name = "rust";
      nativeBuildInputs = [pkgs.pkg-config];
      buildInputs =
        (with pkgs; [
          openssl
          cacert
          rustup
          rust-analyzer
          rustfmt
          tokio-console
          websocat
          protobuf
        ])
        ++ hooks.enabledPackages;
      shellHook =
        ''
          export PATH=$PATH:$HOME/.cargo/bin
          export PROTOBUF_LOCATION=${pkgs.protobuf}
          export PROTOC=$PROTOBUF_LOCATION/bin/protoc
          export PROTOC_INCLUDE=$PROTOBUF_LOCATION/include
        ''
        + hooks.shellHook;
    };
  };
}
