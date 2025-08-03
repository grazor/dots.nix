{
  lib,
  config,
  pkgs,
  ...
}: let
  shellUserImport = ''
    [ -e ~/.fish.user.rc ] && source ~/.fish.user.rc
  '';

  shellInitTmux = ''
    [ -z "$TMUX" ] && tmux new-session -A -s main
  '';

  shellBinPath = ''
    fish_add_path -p ~/.bin
  '';

  shellInitLast =
    shellUserImport
    + (
      if cfg.withScripts
      then shellBinPath
      else ""
    )
    + (
      if cfg.shellInitTmux
      then shellInitTmux
      else ""
    );

  username = config.grazor.user.name;
  cfg = config.grazor.user.config;
  inherit (config.grazor) withNvf;
in {
  options.grazor.user.config.withFish = lib.mkEnableOption "with fish terminal";

  config = lib.mkIf cfg.withFish {
    programs.fish.enable = true;
    grazor.user.shell = lib.mkForce pkgs.fish;

    home-manager.users.${username} = lib.mkIf withNvf {
      home.sessionVariables = {
        EDITOR = "nvim";
      };

      programs = {
        fish = {
          enable = true;
          shellAliases = {
            cat = "bat";
          };
          shellAbbrs = {
            gst = "git status";
            gaa = "git add .";
            gco = "git commit -m";
            gpu = "git push -u origin HEAD";
            grm = "git rebase -i master";
            gpf = "git push --force-with-lease";
            gmt = "go mod tidy";
            t = "tmux new -A -s main";
            k = "kubectl";
          };

          interactiveShellInit = ''
            set fish_greeting
          '';
          inherit shellInitLast;
        };

        bat.enable = true;

        atuin = {
          enable = true;
          enableFishIntegration = true;
          flags = ["--disable-up-arrow"];
        };

        eza = {
          enable = true;
          enableFishIntegration = true;
        };

        direnv.enable = true;

        starship = {
          enable = true;
          enableFishIntegration = true;
        };

        fzf = {
          enable = true;
          enableFishIntegration = true;
        };

        zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    };
  };
}
