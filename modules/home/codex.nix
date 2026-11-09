# Codex defaults and copied skills shared by every Home Manager profile.
{inputs, ...}: {
  flake-file.inputs = {
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zero-slop = {
      url = "github:manavmishra/ZeroSlop";
      flake = false;
    };
    bro-skill = {
      url = "github:luchasarie/bro-skill";
      flake = false;
    };
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    thinking-skills = {
      url = "github:ysskrishna/ai-agent-skills";
      flake = false;
    };
    ui-ux-pro-max = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };
    taste-skill = {
      url = "github:Leonxlnx/taste-skill";
      flake = false;
    };
    ai-research-skills = {
      url = "github:Orchestra-Research/AI-Research-SKILLs";
      flake = false;
    };
    ru-text = {
      url = "github:talkstream/ru-text";
      flake = false;
    };
  };

  flake.modules.homeManager.codex = {
    lib,
    pkgs,
    ...
  }: let
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
    imports = [inputs.agent-skills.homeManagerModules.default];

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
        # Own only this subdirectory; other installers also use .agents/skills.
        dest = "$HOME/.agents/skills/dots";
        # Codex 0.166.0 skips skills with a symlinked SKILL.md. The bundle
        # contains these for transformed skills, so dereference on install.
        structure = "copy-tree";
      };
    };

    # Move only the old bundle's entries, preserving other installed skills.
    home.activation.migrateCodexSkills = lib.hm.dag.entryBetween ["agent-skills"] ["writeBoundary"] ''
      run ${pkgs.python3}/bin/python3 ${./data/migrate-codex-skills.py} "$HOME/.agents/skills"
    '';

    programs.codex = {
      enable = true;
      mutableSettings = true;
      settings = {
        sandbox_mode = "danger-full-access";
        approval_policy = "never";
        tui.status_line = [
          "context-remaining"
          "used-tokens"
          "five-hour-limit"
          "weekly-limit"
        ];
      };
    };
  };
}
