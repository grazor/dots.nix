# Fish shell. The login-shell PATH/tmux hooks are contributed by the `scripts`
# and `tmux-autostart` aspects respectively.
{
  flake.modules.homeManager.fish = {
    programs.fish = {
      enable = true;

      shellAliases.cat = "bat";

      shellAbbrs = {
        gst = "git status";
        gaa = "git add .";
        gcm = "git commit -m";
        gco = "git checkout";
        gpu = "git push -u origin HEAD";
        grm = "git rebase -i master";
        gpf = "git push --force-with-lease";
        gmt = "go mod tidy";
        t = "tmux new -A -s main";
        k = "kubectl";
      };

      interactiveShellInit = ''
        set fish_greeting
        [ -e ~/.fish.user.rc ] && source ~/.fish.user.rc
      '';
    };

    programs.bat.enable = true;

    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--disable-up-arrow"];
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
    };

    # nix-direnv caches `nix print-dev-env` and creates a GC root per project,
    # so `use flake` shells are not re-evaluated/rebuilt on every cd or after
    # nix garbage collection.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
