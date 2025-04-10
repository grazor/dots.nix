{
  pkgs ? import <nixpkgs> {},
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "fleeting-chat";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "grazor";
    repo = pname;
    rev = version;
    hash = "sha256-ee2fB3rpXEON66JbxngM9saCx6smE/drx2HqAxx9JDo=";
  };

  cargoHash = "sha256-erYkcaXLLOmC+Vkn8gly4RzJOr1ihRzb8w794quzVhU=";

  buildInputs = with pkgs; [
    dbus
    openssl
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  meta = {
    description = "Chats to fleeting notes";
    homepage = "https://github.com/grazor/fleeting-chat";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
}
