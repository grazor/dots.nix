# Fish shell. The login-shell PATH/tmux hooks are contributed by the `scripts`
# and `tmux-autostart` aspects respectively.
{
  flake.modules.homeManager.fish = {pkgs, ...}: {
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
        # 18.24.4 has failing Pi session E2E cases on Darwin and a flaky
        # lock-contention case (WouldBlock immediately after releasing the
        # lock). Keep the remaining tests; drop these skips on the next version.
        package =
          if pkgs.stdenv.hostPlatform.isDarwin && pkgs.atuin.version == "18.24.4"
          then
            pkgs.atuin.overrideAttrs (old: {
              checkFlags =
                old.checkFlags
                ++ [
                  "--skip=a_diverged_copy_resumes_only_as_chosen::agent_4_Agent__Pi"
                  "--skip=a_session_gone_on_with_elsewhere_catches_up_where_it_came_from::agent_3_Agent__Pi"
                  "--skip=fs::lock::tests::test_try_open_contention::case_3_exclusive_shared"
                ];
            })
          else pkgs.atuin;
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

        # Atuin owns Ctrl-R (its fish integration is sourced after fzf's, so it
        # won anyway — this just stops home-manager warning about the clash).
        # Ctrl-T (files) and Alt-C (dirs) stay with fzf; up-arrow stays plain
        # fish history, via atuin's --disable-up-arrow above.
        historyWidget.fish.command = "";
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
