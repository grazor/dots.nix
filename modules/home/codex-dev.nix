# Interactive Codex CLI in tmux, with a per-process browser for UI tasks.
{inputs, ...}: {
  flake-file.inputs.agent-skills = {
    url = "github:Kyure-A/agent-skills-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.mcp-servers-nix = {
    url = "github:natsukium/mcp-servers-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.zero-slop = {
    url = "github:manavmishra/ZeroSlop";
    flake = false;
  };
  flake-file.inputs.bro-skill = {
    url = "github:luchasarie/bro-skill";
    flake = false;
  };
  flake-file.inputs.superpowers = {
    url = "github:obra/superpowers";
    flake = false;
  };
  flake-file.inputs.thinking-skills = {
    url = "github:ysskrishna/ai-agent-skills";
    flake = false;
  };
  flake-file.inputs.ui-ux-pro-max = {
    url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
    flake = false;
  };
  flake-file.inputs.taste-skill = {
    url = "github:Leonxlnx/taste-skill";
    flake = false;
  };
  flake-file.inputs.ai-research-skills = {
    url = "github:Orchestra-Research/AI-Research-SKILLs";
    flake = false;
  };
  flake-file.inputs.ru-text = {
    url = "github:talkstream/ru-text";
    flake = false;
  };

  flake.modules.homeManager.codex-dev = {pkgs, ...}: let
    # Taste Skill launches its own Chromium process. This container needs the
    # inner Chromium sandbox disabled, as with the existing Playwright MCP.
    taste-chromium = pkgs.writeShellScriptBin "taste-chromium" ''
      exec ${pkgs.chromium}/bin/chromium --no-sandbox "$@"
    '';
    # brainstorming invokes writing-plans, which invokes this dependency chain.
    # Map plugin-style names to Codex's standalone $skill invocation syntax.
    superpowersSkills = [
      "brainstorming"
      "executing-plans"
      "finishing-a-development-branch"
      "requesting-code-review"
      "subagent-driven-development"
      "systematic-debugging"
      "test-driven-development"
      "using-git-worktrees"
      "verification-before-completion"
      "writing-plans"
    ];
    superpowersSelections = builtins.listToAttrs (map (name: {
        inherit name;
        value = {
          from = "superpowers";
          path = name;
          transform = {original, ...}: builtins.replaceStrings ["superpowers:"] ["$"] original;
        };
      })
      superpowersSkills);
  in {
    imports = [
      inputs.agent-skills.homeManagerModules.default
      inputs.mcp-servers-nix.homeManagerModules.default
    ];

    # Keep sources pinned in flake.lock and expose only the selected skills.
    programs.agent-skills = {
      enable = true;
      sources = {
        local.path = ../../.codex/skills;
        zero-slop = {
          path = inputs.zero-slop;
          subdir = "skills";
          idPrefix = "zero-slop";
        };
        bro = {
          path = inputs.bro-skill;
          filter.maxDepth = 0;
        };
        superpowers = {
          path = inputs.superpowers;
          subdir = "skills";
          idPrefix = "superpowers";
        };
        thinking = {
          path = inputs.thinking-skills;
          subdir = "skills";
          idPrefix = "thinking";
        };
        uiux = {
          path = inputs.ui-ux-pro-max;
          subdir = ".claude/skills";
          idPrefix = "uiux";
        };
        taste = {
          path = inputs.taste-skill;
          subdir = "skills";
          idPrefix = "taste";
        };
        orchestra = {
          path = inputs.ai-research-skills;
          idPrefix = "orchestra";
          filter.maxDepth = 2;
        };
        ru-text = {
          path = inputs.ru-text;
          subdir = "skills";
          idPrefix = "ru-text";
        };
      };
      skills = {
        enableAll = [
          "zero-slop"
          "thinking"
          "taste"
          "orchestra"
          "ru-text"
        ];
        # The main UI/UX skill needs a Codex-safe script path; its six
        # companion skills can be installed unchanged.
        enable = [
          "uiux/banner-design"
          "uiux/brand"
          "uiux/design-system"
          "uiux/design"
          "uiux/slides"
          "uiux/ui-styling"
        ];
        explicit =
          superpowersSelections
          // {
            bro = {
              from = "bro";
              path = ".";
            };
            ui-ux-pro-max = {
              from = "uiux";
              path = "ui-ux-pro-max";
              packages = [pkgs.python3];
              rewriteCommands = false;
              transform = {original, ...}:
                builtins.replaceStrings
                ["python \"\${CLAUDE_PLUGIN_ROOT}/.claude/skills/ui-ux-pro-max/scripts/search.py\""]
                ["${pkgs.python3}/bin/python3 \"${inputs.ui-ux-pro-max}/.claude/skills/ui-ux-pro-max/scripts/search.py\""]
                original;
            };
          };
      };
      targets.agents = {
        enable = true;
        dest = "$HOME/.agents/skills";
        # Codex 0.166.0 skips skills with a symlinked SKILL.md. The bundle
        # contains these for transformed skills, so dereference on install.
        structure = "copy-tree";
      };
    };

    mcp-servers.programs.playwright = {
      enable = true;
      package = pkgs.playwright-mcp;
      # Separate profiles per agent; disable Chromium's inner sandbox for LXC.
      args = ["--headless" "--isolated" "--no-sandbox"];
    };
    programs.mcp.enable = true;

    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      mutableSettings = true;
      settings.sandbox_mode = "danger-full-access";
      settings.approval_policy = "never";
      settings.tui.status_line = [
        "context-remaining"
        "used-tokens"
        "five-hour-limit"
        "weekly-limit"
      ];
      context = ''
        This is a persistent NixOS development container, accessed over SSH.
        Projects live under ~/src, with separate tmux windows/sessions.
        Check each repo's AGENTS.md and .envrc, including parent directories.
        For direnv-managed repos run environment-dependent commands through
        direnv exec <project-root> <command> from the appropriate directory.
        Use each project's flake/toolchain when present.
        Playwright MCP provides a local browser for UI checks and screenshots.
        Dev servers bound to 127.0.0.1 can be viewed from the laptop using SSH
        local port forwarding; no firewall changes are needed for that.
      '';
    };

    home.packages = with pkgs; [playwright-test playwright-mcp python3 nodejs];
    home.sessionPath = ["$HOME/.local/bin"];
    home.sessionVariables.CHROME_PATH = "${taste-chromium}/bin/taste-chromium";

    home.file."src/.keep".text = "";
  };
}
