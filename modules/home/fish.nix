# Fish shell. The login-shell PATH/tmux hooks are contributed by the `scripts`
# and `tmux-autostart` aspects respectively.
{
  flake.modules.homeManager.fish = {
    programs = {
      fish = {
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

      # nix-direnv caches `nix print-dev-env` and creates a GC root per project,
      # so `use flake` shells are not re-evaluated/rebuilt on every cd or after
      # nix garbage collection.
      direnv = {
        enable = true;
        nix-direnv.enable = true;

        # Sourced on every .envrc load, with $PWD at the .envrc's directory (the
        # project root, even when entered from a subdir). Name the current tmux
        # window after the project. Fires for any direnv dir, not just ones set up
        # via `bin/project`. `|| true` keeps a non-tmux shell from erroring.
        stdlib = ''
          [ -n "$TMUX" ] && tmux rename-window "$(basename "$PWD")" >/dev/null 2>&1 || true
        '';
      };

      starship = {
        enable = true;
        enableFishIntegration = true;
        enableTransience = true;
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
}
