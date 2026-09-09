# Neovim via nvf, configured through home-manager so it is identical on NixOS
# and nix-darwin.
{inputs, ...}: {
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Not in nixpkgs' vimPlugins, so it is pinned as a source-only input and
  # packaged below.
  flake-file.inputs.postilla-nvim = {
    url = "github:eltonsst/postilla.nvim";
    flake = false;
  };

  flake.modules.homeManager.nvf = {
    pkgs,
    lib,
    ...
  }: let
    postilla-nvim = pkgs.vimUtils.buildVimPlugin {
      pname = "postilla.nvim";
      version = inputs.postilla-nvim.shortRev or "unstable";
      src = inputs.postilla-nvim;
      meta.homepage = "https://github.com/eltonsst/postilla.nvim";
    };

    # Neovim's runtime ships an `en` spellfile only. Compiling `ru` from the
    # LibreOffice hunspell dictionary keeps `spelllang=en,ru` declarative --
    # otherwise spellfile.vim prompts to download one into ~/.local at runtime.
    ruSpellfile =
      pkgs.runCommandLocal "nvim-spell-ru" {
        nativeBuildInputs = [pkgs.neovim-unwrapped];
      } ''
        set -eu
        mkdir -p "$out/spell" build
        cp ${pkgs.hunspellDicts.ru_RU}/share/hunspell/ru_RU.aff build/ru.aff
        cp ${pkgs.hunspellDicts.ru_RU}/share/hunspell/ru_RU.dic build/ru.dic
        cd build
        nvim --headless --clean --cmd "set encoding=utf-8" \
          --cmd "mkspell! $out/spell/ru.utf-8.spl ru" --cmd qa
      '';
  in {
    imports = [inputs.nvf.homeManagerModules.default];

    home.sessionVariables.EDITOR = "nvim";

    programs.nvf = {
      enable = true;

      settings.vim = {
        # vim.loader.enable(): bytecode cache for lua modules, cuts startup.
        enableLuaLoader = true;
        extraPackages = [pkgs.fzf pkgs.ripgrep];
        additionalRuntimePaths = [ruSpellfile.outPath];

        globals.mapleader = " ";
        lineNumberMode = "number";
        undoFile.enable = true;
        preventJunkFiles = true;
        withPython3 = true;
        searchCase = "smart";

        clipboard = {
          enable = true;
          providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;
          registers = "unnamedplus";
        };

        options = {
          mouse = "n";
          shiftwidth = 4;
          tabstop = 4;
          signcolumn = "yes";
          splitbelow = true;
          splitright = true;

          # `spellcheck.enable` sets `spell` globally, which underlines every
          # identifier in code. Force it off and let the autocmd below turn it
          # back on for prose buffers only.
          spell = lib.mkForce false;
        };

        autocmds = [
          {
            event = ["FileType"];
            pattern = ["markdown" "gitcommit" "text" "asciidoc"];
            command = "setlocal spell";
            desc = "Spellcheck prose buffers only";
          }
        ];

        theme = {
          enable = true;
          # Priority 500 sits between nvf's own default (mkDefault, 1000) and a
          # normal definition (100): it beats nvf's default so hosts keep
          # tokyonight, but loses to stylix's normal-priority base16 on the
          # desktop, so stylix themes nvf there.
          name = lib.mkOverride 500 "tokyonight";
          transparent = false;
          style = "night";
        };

        autocomplete = {
          nvim-cmp = {
            enable = true;

            # nvf installs cmp-buffer and cmp-path unconditionally
            # (`sourcePlugins`), but only registers what is in `sources` --
            # whose default is dropped as soon as anything defines that option,
            # and both the lsp and treesitter modules do. Without these two the
            # plugins load and are never used.
            sources = {
              buffer = "[Buffer]";
              path = "[Path]";
            };
          };

          blink-cmp.enable = false;
        };

        mini = {
          ai.enable = true;
          fuzzy.enable = false;
          splitjoin.enable = true;
        };

        telescope.enable = true;

        autopairs.nvim-autopairs.enable = true;
        binds.whichKey.enable = true;
        comments.comment-nvim.enable = true;
        dashboard.alpha.enable = true;
        git.enable = true;
        notes.todo-comments.enable = true;
        spellcheck = {
          enable = true;
          languages = ["en" "ru"];
        };

        treesitter = {
          # Sticky header showing the enclosing function/block.
          context.enable = true;
          # af/if/ac/ic textobjects and function-wise motions.
          textobjects.enable = true;
        };

        filetree.nvimTree = {
          enable = true;
          openOnSetup = false;
        };

        ui = {
          fastaction.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
          smartcolumn.enable = true;
        };

        utility = {
          motion.leap.enable = true;
          surround.enable = true;

          # Reads .envrc, so per-project devshell tooling reaches the LSPs.
          direnv.enable = true;

          # Edit a directory as a normal buffer; complements nvimTree rather
          # than replacing it.
          oil-nvim.enable = true;

          # Owns <C-hjkl> (see the keymaps list below, where the plain
          # <C-w> equivalents used to live) and hands the motion off to the
          # multiplexer when there is no split left in that direction.
          smart-splits.enable = true;
        };

        visuals = {
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;
          nvim-cursorline.enable = true;
          rainbow-delimiters.enable = true;

          cinnamon-nvim = {
            enable = true;
            setupOpts.keymaps.basic = true;
          };

          nvim-web-devicons = {
            enable = true;
            setupOpts.variant = "dark";
          };
        };

        # postilla.nvim: annotate agent-written code line by line in a normal
        # buffer and export the notes in revdiff's annotation format
        # (`## file:line`), ready to paste back to the agent. Not an nvf module
        # -- nvf's `assistant.*` plugins are all completion/chat, none do
        # review -- so it is wired up through extraPlugins.
        extraPlugins.postilla = {
          package = postilla-nvim;
          setup = ''
            require("postilla").setup({
              keymap = "<leader>rc",
              next_keymap = "]r",
              previous_keymap = "[r",
            })
          '';
        };

        tabline.nvimBufferline.enable = false;

        statusline.lualine.enable = true;

        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableExtraDiagnostics = true;

          bash.enable = true;
          go.enable = true;
          lua.enable = true;
          nix = {
            enable = true;
            format.enable = true;
          };
          markdown = {
            enable = true;
            # Left off deliberately: lsp.formatOnSave is on, and a markdown
            # formatter would rewrite every existing doc on the first save.
            format.enable = false;
          };
          python = {
            enable = true;
            lsp.enable = true;
            format.enable = false;
          };
          rust.enable = true;

          typescript.enable = false;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = true;
        };

        keymaps = [
          {
            key = "jk";
            mode = ["i"];
            action = "<ESC>";
            silent = true;
            desc = "Exit input mode";
          }
          {
            key = "<leader>e";
            mode = ["n"];
            action = '':e <C-R>=expand("%:p:h")<CR>/'';
            desc = "Relative path";
          }
          {
            key = "<Esc>";
            mode = ["n"];
            action = "<cmd>nohlsearch<CR>";
            desc = "Clear highlight";
          }
          {
            key = "<leader>/";
            mode = ["n"];
            action = "<cmd>nohlsearch<CR>";
            desc = "Clear highlight";
          }
        ];
      };
    };
  };
}
