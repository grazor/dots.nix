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

dev['glepnir/smartinput.nvim'] = {
  ft = { 'go' },
  config = function() 
      require('smartinput').setup {
        ['go'] = { ';',':=',';'}
    }
  end
}

dev['AckslD/nvim-revJ.lua'] = {
    after = 'nvim-treesitter',
    requires = {'kana/vim-textobj-user', 'sgur/vim-textobj-parameter'},
    config = function() 
        require("revj").setup{
            keymaps = {
                operator = '<Leader>J', -- for operator (+motion)
                line = '<Leader>j', -- for formatting current line
                visual = '<Leader>j', -- for formatting visual selection
            },
        }
    end
}

return dev
