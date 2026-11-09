# Zsh with fish-style editing, without a framework or runtime plugin manager.
# The login-shell PATH/tmux hooks are contributed by the `scripts`
# and `tmux-autostart` aspects respectively.
{
  flake.modules.homeManager.zsh = {
    config,
    lib,
    ...
  }: {
    programs = {
      zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        defaultKeymap = "emacs";
        autocd = true;
        enableCompletion = true;

        autosuggestion = {
          enable = true;
          strategy = ["history" "completion"];
        };
        syntaxHighlighting.enable = true;
        historySubstringSearch = {
          enable = true;
          # Normal and application cursor modes (Ghostty, tmux, SSH).
          searchUpKey = ["^[[A" "^[OA"];
          searchDownKey = ["^[[B" "^[OB"];
        };

        history = {
          path = "${config.xdg.dataHome}/zsh/history";
          size = 100000;
          save = 100000;
          extended = true;
          share = true;
          ignoreSpace = true;
          expireDuplicatesFirst = true;
        };

        # Fish abbreviations become ordinary zsh aliases.
        shellAliases = {
          cat = "bat";
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

        # Keep an existing, unmanaged login profile usable with XDG dotfiles.
        profileExtra = ''
          [[ ! -f "$HOME/.zprofile" ]] || source "$HOME/.zprofile"
        '';

        initContent = lib.mkMerge [
          (lib.mkOrder 550 ''
            # Machine-local settings use zsh syntax and stay out of the store.
            [[ ! -f "$HOME/.zsh.user.rc" ]] || source "$HOME/.zsh.user.rc"
          '')
          ''
            setopt INTERACTIVE_COMMENTS
            zmodload zsh/complist
            zstyle ':completion:*' menu select
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

            # Accept the inline suggestion at end of line; otherwise move right.
            bindkey '^[[C' forward-char
            bindkey '^[OC' forward-char
          ''
        ];
      };

      bat.enable = true;

      eza = {
        enable = true;
        enableZshIntegration = true;
      };

      # nix-direnv caches `nix print-dev-env` and creates a GC root per project,
      # so `use flake` shells are not re-evaluated/rebuilt on every cd or after
      # nix garbage collection.
      direnv = {
        enable = true;
        enableZshIntegration = true;
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
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
