local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = {
      {'ray-x/lsp_signature.nvim'},
      {'simrat39/rust-tools.nvim'},
  },
}

completion['glepnir/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
}

completion['ms-jpq/coq_nvim'] = {
    branch = 'coq',
    requires = {'ms-jpq/coq.artifacts', branch='atifacts'},
    config = function() 
        vim.g.coq_settings = {
            auto_start = 'shut-up',
            display = {
                ghost_text = {enabled=true},
                pum = {fast_close=false},
            },
            keymap = {jump_to_mark = ''},
        }
    end
}

return completion
