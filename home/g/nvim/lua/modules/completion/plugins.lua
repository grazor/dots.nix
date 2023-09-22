local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = 'hrsh7th/cmp-nvim-lsp',
}

completion['tami5/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
  config = conf.lspsaga,
  requires = 'neovim/nvim-lspconfig',
}

completion['nvim-telescope/telescope.nvim'] = {
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true}, {'nvim-lua/plenary.nvim', opt = true},
    {'nvim-telescope/telescope-fzy-native.nvim'},
  },
}

--completion['glepnir/smartinput.nvim'] = {ft = 'go', config = conf.smart_input}

completion['hrsh7th/nvim-cmp'] = {
  requires = {
    'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
  },
  config = conf.nvim_cmp,
}

completion['L3MON4D3/LuaSnip'] = {config = conf.luasnip}

completion['ray-x/lsp_signature.nvim'] = {config = conf.lsp_signature}

return completion
