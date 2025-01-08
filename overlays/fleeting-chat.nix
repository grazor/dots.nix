{
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
    hash = "";
  };

  cargoHash = "";

  meta = {
    description = "Chats to fleeting notes";
    homepage = "https://github.com/grazor/fleeting-chat";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
