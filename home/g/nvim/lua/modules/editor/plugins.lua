local editor = {}
local conf = require('modules.editor.config')

editor['rhysd/accelerated-jk'] = {opt = true}

editor['lewis6991/gitsigns.nvim'] = {
  config = conf.gitsigns,
  requires = {'nvim-lua/plenary.nvim', opt = true},
}

editor['ruifm/gitlinker.nvim'] = {
  config = conf.gitlinker,
  requires = {'nvim-lua/plenary.nvim', opt = true},
}

editor['windwp/nvim-autopairs'] = {
  config = conf.autopairs,
  requires = {'hrsh7th/nvim-cmp', opt = true},
}

editor['AckslD/nvim-trevJ.lua'] = {
  config = conf.trevj,
  after = 'nvim-treesitter',
}

editor['yamatsum/nvim-cursorline'] = {config = conf.cursorline}

editor['lukas-reineke/indent-blankline.nvim'] = {
  config = conf.indent,
  after = 'nvim-treesitter',
}

editor['karb94/neoscroll.nvim'] = {config = conf.neoscroll}

editor['echasnovski/mini.nvim'] = {config = conf.mini}

return editor
