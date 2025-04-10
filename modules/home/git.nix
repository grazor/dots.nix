{
  lib,
  config,
  ...
}: let
  username = config.grazor.user.name;
  cfg = config.grazor.user.config;
in {
  options.grazor.user.config.withGit = lib.mkEnableOption "with git config";
  config = lib.mkIf cfg.withFonts {
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
        ".envrc"
        ".lefthook"
        ".direnv"
      ];
    };
  };
}
