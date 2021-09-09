local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
}

completion['glepnir/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
}

completion['ms-jpq/coq_nvim'] = {
    branch = 'coq',
    requires = {'ms-jpq/coq.artifacts', branch='atifacts'},
    config = function() 
        vim.g.coq_settings = {auto_start = 'shut-up'}
    end
}


return completion
