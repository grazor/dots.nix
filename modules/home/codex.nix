# Codex defaults and copied skills shared by every Home Manager profile.
{inputs, ...}: {
  flake-file.inputs = {
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    hallmark = {
      url = "github:nutlope/hallmark";
      flake = false;
    };
    agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    zero-slop = {
      url = "github:manavmishra/ZeroSlop";
      flake = false;
    };
    bro-skill = {
      url = "github:luchasarie/bro-skill";
      flake = false;
    };
    antialgorithm = {
      url = "github:mankidev/antialgorithm";
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
    antialgorithmPython = pkgs.python3.withPackages (ps: [ps.numpy ps.pillow ps.cairosvg]);
    reaVersion = "6.10.1";
    reaRelease = pkgs.fetchurl {
      url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${reaVersion}.tgz";
      hash = "sha512-3AWrfFEXppvC98FWhZR2Tzulnqs5xJQrSKmAub6+QME/I58Pr3h8pHqqwM30z2DvlnIx/8Hsu8woMngfi4SNyg==";
    };
    reaRuntime =
      pkgs.runCommand "rea-runtime-${reaVersion}" {
        nativeBuildInputs = [pkgs.gnutar pkgs.gzip];
      } ''
        mkdir -p "$out"
        tar -xzf ${reaRelease} -C "$out" --strip-components=1
        test -f "$out/scripts/rea.mjs"
      '';
    rea = "${pkgs.nodejs_26}/bin/node ${reaRuntime}/scripts/rea.mjs";
    reaInspect = pkgs.writeShellApplication {
      name = "rea-inspect";
      text = ''
        if [[ $# != 2 || $2 != /* ]]; then
          echo 'Usage: rea-inspect {ipa|ipa-graph|javascript|dotnet|dotnet-members} /absolute/path' >&2
          exit 2
        fi

        case "$1" in
          ipa|ipa-graph)
            if [[ "$2" != *.ipa || ! -f "$2" ]]; then
              echo 'IPA inspection requires a local .ipa file.' >&2
              exit 2
            fi
            command=inspect-artifact
            ;;
          javascript) command=analyze-javascript-application ;;
          dotnet) command=inspect-managed-artifact ;;
          dotnet-members) command=inspect-managed-members ;;
          *)
            echo "Unknown inspection type: $1" >&2
            exit 2
            ;;
        esac

        ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # The Nix SDK can be active without a Swift compiler. REA supervises
          # its JavaScript parser using a helper built with the Apple toolchain.
          if [[ "$1" == javascript ]] && ! /usr/bin/xcrun --find swiftc >/dev/null 2>&1 &&
             [[ -x /Library/Developer/CommandLineTools/usr/bin/swiftc ]]; then
            export DEVELOPER_DIR=/Library/Developer/CommandLineTools
            unset SDKROOT
          fi
        ''}

        if [[ "$1" == ipa-graph ]]; then
          ${rea} "$command" "$2" --json |
            ${lib.getExe pkgs.jq} -ce '{
              inventory_evidence: [.normalized_result.substeps[] |
                select(.operation == "inventory_artifact" and .status == "completed") |
                .evidence]
            }' |
            ${rea} project-apple-application-graph - --json
        else
          exec ${rea} "$command" "$2" --json
        fi
      '';
    };
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
        anthropic = {
          path = inputs.anthropic-skills;
          subdir = "skills";
          idPrefix = "anthropic";
        };
        hallmark = {
          path = inputs.hallmark;
          subdir = "skills";
        };
        agent-browser = {
          path = inputs.agent-browser;
          subdir = "skills";
        };
        zero-slop = {
          path = inputs.zero-slop;
          subdir = "skills";
          idPrefix = "zero-slop";
        };
        bro = {
          path = inputs.bro-skill;
          filter.maxDepth = 0;
        };
        antialgorithm = {
          path = inputs.antialgorithm;
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
        enable = [
          "rea-static-inspection"
          "hallmark"
          "agent-browser"
          "anthropic/skill-creator"
          "anthropic/frontend-design"
          "anthropic/theme-factory"
          "anthropic/mcp-builder"
          # The main UI/UX skill needs a Codex-safe script path; its six
          # companion skills can be installed unchanged.
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
            antialgorithm = {
              from = "antialgorithm";
              path = ".";
              # The absolute command retains its runtime without enumerating
              # package binaries during evaluation (including foreign hosts).
              rewriteCommands = false;
              transform = {original, ...}:
                builtins.replaceStrings
                ["left open to Claude" "python3 scripts/"]
                ["left open to the agent" "${antialgorithmPython}/bin/python3 ${inputs.antialgorithm}/scripts/"]
                original;
            };
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

    home = {
      packages = [pkgs.agent-browser pkgs.nodejs reaInspect];
      sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (let
        chromium = lib.getExe pkgs.chromium;
      in {
        CHROME_PATH = lib.mkDefault chromium;
        AGENT_BROWSER_EXECUTABLE_PATH = lib.mkDefault chromium;
      });

      # Move only the old bundle's entries, preserving other installed skills.
      activation.migrateCodexSkills = lib.hm.dag.entryBetween ["agent-skills"] ["writeBoundary"] ''
        run ${pkgs.python3}/bin/python3 ${./data/migrate-codex-skills.py} "$HOME/.agents/skills"
      '';
    };

    programs.codex = {
      enable = true;
      mutableSettings = true;
      settings = {
        sandbox_mode = "danger-full-access";
        approval_policy = "never";
        features.code_mode = true;
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
