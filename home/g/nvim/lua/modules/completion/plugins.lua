local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = 'ray-x/lsp_signature.nvim'
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
                ghost_text = {enabled=false},
            },
        }
    end
}

completion['simrat39/symbols-outline.nvim'] = {
    config = function()
        vim.g.symbols_outline = {
            auto_preview = false,
        }
    end
}

return completion
