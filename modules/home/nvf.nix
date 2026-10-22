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
          nvim-cmp.enable = false;

          # Default sources are lsp, path, snippets and buffer; nvf's mappings
          # match the old nvim-cmp ones (<Tab>/<S-Tab>, <CR>, <C-Space>, <C-e>).
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
        };

        mini = {
          ai.enable = true;
          fuzzy.enable = false;
          splitjoin.enable = true;
        };

        telescope = {
          enable = true;
          # fzf-native sorter: space-separated words are separate fuzzy terms
          # that all have to match ("skill ff-start README md"), instead of
          # the space being matched literally. Also gives fzf's 'exact, ^prefix,
          # suffix$ and !negation syntax.
          extensions = [
            {
              name = "fzf";
              packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
              setup.fzf.fuzzy = true;
            }
          ];
        };

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

        ui = {
          fastaction.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
          smartcolumn.enable = true;
        };

        utility = {
          # s / S jumps, labels on / search results (toggle with <C-s>).
          motion.flash-nvim.enable = true;
          surround.enable = true;

          # Reads .envrc, so per-project devshell tooling reaches the LSPs.
          direnv.enable = true;

          # Edit a directory as a normal buffer. It keeps handling `nvim <dir>`,
          # so yazi below leaves open_for_directories off.
          oil-nvim.enable = true;

          # Floating yazi in place of the old nvimTree, on its <leader>t key.
          # The yazi binary comes from the `yazi` home module. The default
          # resume key, <C-Up>, is swallowed by macOS workspace switching.
          yazi-nvim = {
            enable = true;
            mappings = {
              openYazi = "<leader>t";
              openYaziDir = "<leader>T";
              yaziToggle = "<leader>-";
            };
          };

          # Owns <C-hjkl> (see the keymaps list below, where the plain
          # <C-w> equivalents used to live) and hands the motion off to the
          # multiplexer when there is no split left in that direction.
          smart-splits = {
            enable = true;

            # Resize has to dodge three layers above Neovim on this box:
            # upstream's <A-hjkl> dies because Ghostty leaves
            # `macos-option-as-alt` unset (Option is a Unicode compose key),
            # <C-arrow> is swallowed by macOS workspace switching, and
            # <C-S-hjkl> does not survive the Karabiner Ctrl remap. Ctrl+Shift
            # +arrow is the one combination left free. Arrows also carry the
            # modifier inside their CSI sequence (CSI 1;6D), so this needs no
            # kitty keyboard protocol -- unlike <C-S-h>, which is byte-identical
            # to <C-h> under legacy encoding.
            keymaps = {
              resize_left = "<C-S-Left>";
              resize_down = "<C-S-Down>";
              resize_up = "<C-S-Up>";
              resize_right = "<C-S-Right>";
            };
          };
        };

        visuals = {
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;
          nvim-cursorline.enable = true;
          rainbow-delimiters.enable = true;

          # Not cinnamon-nvim: on wrapped lines (wide markdown tables) its
          # animation never converges -- it jitters up/down until its timeout
          # and leaves the cursor mid-scroll, and it also hijacks n/N.
          # neoscroll only animates the scroll keys and leaves search native.
          neoscroll-nvim = {
            enable = true;
            # <C-u>/<C-d> are left out and mapped in `keymaps` below: the
            # built-in ones keep the cursor on its screen row, those keep it on
            # its text line.
            setupOpts.mappings = ["<C-b>" "<C-f>" "<C-y>" "<C-e>" "zt" "zz" "zb"];
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
            # Renders headings, tables and checkboxes in place; the cursor
            # line is shown raw. `:RenderMarkdown toggle` switches it off.
            extensions.render-markdown-nvim.enable = true;
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
            key = "<C-u>";
            mode = ["n" "x"];
            lua = true;
            action = ''function() require("neoscroll").scroll(-vim.wo.scroll, {move_cursor = false, duration = 250}) end'';
            desc = "Scroll half a window up";
          }
          {
            key = "<C-d>";
            mode = ["n" "x"];
            lua = true;
            action = ''function() require("neoscroll").scroll(vim.wo.scroll, {move_cursor = false, duration = 250}) end'';
            desc = "Scroll half a window down";
          }
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
