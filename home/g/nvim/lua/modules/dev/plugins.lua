local dev = {}
local conf = require('modules.dev.config')

dev['nvim-treesitter/nvim-treesitter'] = {
  event = 'BufRead',
  after = 'telescope.nvim',
  config = conf.nvim_treesitter,
}

dev['nvim-treesitter/nvim-treesitter-textobjects'] = {
  after = 'nvim-treesitter'
}

dev['p00f/nvim-ts-rainbow'] = {
  after = 'nvim-treesitter'
}

dev['mizlan/iswap.nvim'] = {
  after = 'nvim-treesitter'
}

dev['editorconfig/editorconfig-vim'] = {
  ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp','python' }
}

return dev
