# Zsh with fish-style editing, without a framework or runtime plugin manager.
# The login-shell PATH/tmux hooks are contributed by the `scripts`
# and `tmux-autostart` aspects respectively.
{
  flake.modules.homeManager.zsh = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.zsh-forgit];

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
          # Use a fixed gray instead of the terminal's bright-black palette slot.
          highlight = "fg=#6c6c6c";
        };
        syntaxHighlighting = {
          enable = true;
          highlighters = ["regexp"];
        };
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

        shellAliases.cat = "bat";

        # Expand fish-style shortcuts into editable command text on Space/Enter.
        zsh-abbr = {
          enable = true;
          abbreviations = {
            gst = "git status";
            gaa = "git add .";
            # % places the cursor without inserting the triggering Space.
            gcm = "git commit -m '%'";
            gco = "git checkout";
            gco- = "git checkout -";
            gpu = "git push -u origin HEAD";
            grm = "git rebase -i master";
            gpf = "git push --force-with-lease";
            gmt = "go mod tidy";
            t = "tmux new -A -s main";
            k = "kubectl";
          };
        };

        # Keep an existing, unmanaged login profile usable with XDG dotfiles.
        profileExtra = ''
          [[ ! -f "$HOME/.zprofile" ]] || source "$HOME/.zprofile"
        '';

        initContent = lib.mkMerge [
          (lib.mkOrder 550 ''
            ABBR_SET_EXPANSION_CURSOR=1

            # Register extra completions before compinit builds its cache.
            fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions ${pkgs.zsh-forgit}/share/zsh/site-functions)
            zstyle ':completion:*' menu no
            zstyle ':completion:*:descriptions' format '[%d]'
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
            zstyle ':completion:*:git-checkout:*' sort false
            zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always -- $realpath'

            # Machine-local settings use zsh syntax and stay out of the store.
            [[ ! -f "$HOME/.zsh.user.rc" ]] || source "$HOME/.zsh.user.rc"
          '')
          # fzf-tab must follow compinit (570) and precede autosuggestions (700).
          (lib.mkOrder 600 ''
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          '')
          (lib.mkOrder 950 ''
            # Preserve zsh-abbr's Space binding; pair only quotes and brackets.
            AUTOPAIR_INHIBIT_INIT=1
            source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
            unset 'AUTOPAIR_PAIRS[ ]'
            autopair-init

            # Keep gco as the git checkout abbreviation.
            forgit_checkout_commit=gcoi
            source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh
          '')
          ''
            setopt INTERACTIVE_COMMENTS
            zmodload zsh/complist

            # Prefer origin's recorded default branch, then conventional names.
            function gcom() {
              command git rev-parse --git-dir >/dev/null || return $?
              local branch
              if branch=$(command git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null); then
                command git -c checkout.defaultRemote=origin switch "''${branch#origin/}" "$@"
                return $?
              fi
              for branch in main master; do
                if command git show-ref --verify --quiet "refs/heads/$branch" ||
                   command git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                  command git -c checkout.defaultRemote=origin switch "$branch" "$@"
                  return $?
                fi
              done
              print -u2 -- "gcom: cannot determine the primary branch (no origin/HEAD, main, or master)"
              return 1
            }

            # Ctrl-W deletes components in paths, URLs, and other compound words.
            autoload -Uz backward-kill-word-match
            zle -N backward-kill-component backward-kill-word-match
            zstyle ':zle:backward-kill-component' word-style unspecified
            zstyle ':zle:backward-kill-component' word-chars $' \t\n/=:,@#{}\'"|&;()<>'
            bindkey '^W' backward-kill-component

            # Accept the inline suggestion at end of line; otherwise move right.
            bindkey '^[[C' forward-char
            bindkey '^[OC' forward-char
          ''
          (lib.mkOrder 1500 ''
            # Rename only on successful zoxide jumps, after zoxide initializes.
            function _dots_zoxide_tmux_jump() {
              local old_pwd=$PWD window_name
              "$@" || return $?
              if [[ -n $TMUX && -n $TMUX_PANE && $PWD != $old_pwd ]]; then
                window_name=''${PWD:t}
                # tmux expands formats in names; escape hashes to keep them literal.
                command tmux rename-window -t "$TMUX_PANE" -- "''${window_name//\#/##}" >/dev/null 2>&1 || true
              fi
              return 0
            }

            function z() { _dots_zoxide_tmux_jump __zoxide_z "$@"; }
            function zi() { _dots_zoxide_tmux_jump __zoxide_zi "$@"; }
          '')
          (lib.mkOrder 1500 ''
            # zsh-abbr shortcuts are not aliases: teach the highlighter their names
            # after both plugins have loaded. Match complete input, not prefixes.
            if (( ''${#ABBR_REGULAR_USER_ABBREVIATIONS} )); then
              ZSH_HIGHLIGHT_REGEXP+=(
                "^[[:space:]]*("''${(j:|:)''${(Qk)ABBR_REGULAR_USER_ABBREVIATIONS}}")$"
                "$ZSH_HIGHLIGHT_STYLES[arg0]"
              )
            fi
          '')
          (lib.mkOrder 1500 ''
            # Capture Starship's prompt after its initialization, then collapse
            # submitted prompts to its themed character (fish-style transience).
            if [[ $TERM != dumb ]]; then
              TRANSIENT_PROMPT_TRANSIENT_PROMPT=$'\n$(${lib.getExe config.programs.starship.package} module character --status="''${STARSHIP_CMD_STATUS:-0}" --keymap="''${KEYMAP:-}")'
              TRANSIENT_PROMPT_TRANSIENT_RPROMPT=""
              source ${pkgs.fetchFromGitHub {
              owner = "olets";
              repo = "zsh-transient-prompt";
              rev = "ba98fe847ffb31c5529441e14c5a228a74903a75"; # v1.0.1
              hash = "sha256-v4RuB/LL5/6d0FPDPrheFN5o1ZXKjIbfThz/sKSEuII=";
            }}/transient-prompt.zsh-theme
            fi
          '')
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
