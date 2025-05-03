{
  lib,
  config,
  ...
}: let
  username = config.grazor.user.name;
  cfg = config.grazor.user.config;
in {
  options.grazor.user.config.withGit = lib.mkEnableOption "with git config";
  config = lib.mkIf cfg.withGit {
    home-manager.users.${username}.programs.git = {
      enable = true;
      lfs.enable = true;
      userName = "Sergey Poryvaev";
      userEmail = "porivaevs@gmail.com";
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };
      ignores = [
        ".direnv"
        ".envrc"
        ".lefthook"
        ".venv"
        "Pipfile"
        "Pipfile.lock"
        "__debug_bin"
        "_build"
        "debug.test"
        "default.nix"
        "lefthook.yaml"
        "lefthook.yml"
        "ptest"
        "tags"
      ];
    };
  };
}
