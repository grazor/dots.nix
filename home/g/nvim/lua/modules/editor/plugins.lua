local editor = {}
local conf = require('modules.editor.config')

editor['nvim-telescope/telescope.nvim'] = {
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim',opt = true},
  }
}

editor['rhysd/accelerated-jk'] = {
  opt = true
}

editor['dyng/ctrlsf.vim'] = {}

editor['f-person/git-blame.nvim'] = {
  config = function()
    vim.g.gitblame_message_template = '        <author> • <date> • <summary>'
  end
}

editor['itchyny/vim-cursorword'] = {
  event = {'BufReadPre','BufNewFile'},
  config = conf.vim_cursorwod
}

editor['karb94/neoscroll.nvim'] = {
  config = function()
    require('neoscroll').setup()
  end
}

editor['phaazon/hop.nvim'] = {
  as = 'hop',
  config = function()
    require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
  end
}

editor['windwp/nvim-autopairs'] = {
    config = function()
        require('nvim-autopairs').setup{}
    end
}

editor['plasticboy/vim-markdown'] = {
    requires = 'godlygeek/tabular',
}

return editor
