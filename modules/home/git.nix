{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user.name = "Sergey Poryvaev";
        user.email = "porivaevs@gmail.com";
        alias = {
          ci = "commit";
          co = "checkout";
          s = "status";
        };
      };

      ignores = [
        ".direnv"
        ".envrc"
        ".pre-commit-config.yaml"
        ".venv"
        "Pipfile"
        "Pipfile.lock"
        "__debug_bin"
        "_build"
        "debug.test"
        "ptest"
        "tags"
      ];
    };

    home.sessionVariables."GIT_ADVICE" = "0";
  };
}
