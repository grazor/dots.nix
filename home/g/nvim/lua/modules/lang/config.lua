local config = {}

function config.nvim_treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash", "c", "cpp", "go", "gomod", "rust", "json", "latex", "make", "nix",
      "php", "python", "toml", "yaml",
    },
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  }
end

return config
