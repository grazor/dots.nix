{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.grazor;
in {
  options.grazor.withNvf = lib.mkEnableOption "install nvf";
  config = lib.mkIf cfg.withNvf {
    programs.nvf = {
      enable = true;

      settings.vim = {
        enableLuaLoader = false;
        extraPackages = [pkgs.fzf pkgs.ripgrep];

        globals.mapleader = " ";
        lineNumberMode = "number";
        undoFile = {
          enable = false;
        };
        preventJunkFiles = true;
        withPython3 = true;
        searchCase = "smart";

        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };

        options = {
          mouse = "n";
          shiftwidth = 4;
          tabstop = 4;
          signcolumn = "yes";
          splitbelow = true;
          splitright = true;
        };

        theme = {
          enable = true;
          name = "tokyonight";
          transparent = false;
          style = "night";
        };

        autocomplete = {
          nvim-cmp.enable = true;
          blink-cmp.enable = false;
        };

        mini.fuzzy.enable = false;
        mini.splitjoin.enable = true;

        telescope.enable = true;

        autopairs.nvim-autopairs.enable = true;
        binds.whichKey.enable = true;
        comments.comment-nvim.enable = true;
        dashboard.alpha.enable = true;
        git.enable = true;
        minimap.codewindow.enable = true;
        notes.todo-comments.enable = true;
        spellcheck.enable = false;

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
        };

        visuals = {
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;
          nvim-cursorline.enable = true;

          cinnamon-nvim = {
            enable = true;
            setupOpts.keymaps.basic = true;
          };

          nvim-web-devicons = {
            enable = true;
            setupOpts.variant = "dark";
          };
        };

        tabline.nvimBufferline.enable = false;

        statusline.lualine = {
          enable = true;
        };

        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableExtraDiagnostics = true;

          bash.enable = true;
          go.enable = true;
          lua.enable = true;
          nix.enable = true;
          markdown = {
            enable = false; # no deno pls
            format.enable = false;
          };
          python = {
            enable = true;
            lsp.enable = false;
            format.enable = false;
          };
          rust.enable = true;

          ts.enable = false;
        };

        lsp.enable = true;
        lsp.formatOnSave = false;

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
            key = "<C-h>";
            mode = ["n"];
            action = "<C-w><C-h>";
            desc = "Move focus to the left window";
          }
          {
            key = "<C-l>";
            mode = ["n"];
            action = "<C-w><C-l>";
            desc = "Move focus to the right window";
          }
          {
            key = "<C-j>";
            mode = ["n"];
            action = "<C-w><C-j>";
            desc = "Move focus to the lower window";
          }
          {
            key = "<C-k>";
            mode = ["n"];
            action = "<C-w><C-k>";
            desc = "Move focus to the upper window";
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
