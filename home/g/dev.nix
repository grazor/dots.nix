{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Sergey Poryvaev";
    ignores = [
      "tags"
      ".venv"
      "Pipfile"
      "Pipfile.lock"
      "ptest"
      "_build"
      "__debug_bin"
      "debug.test"
      ".envrc"
      "default.nix"
      "lefthook.yml"
      ".lefthook"
    ];
  };
}
