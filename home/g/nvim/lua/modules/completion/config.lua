local config = {}

function config.nvim_lsp()
  require('modules.completion.lspconfig')
  require('lsp_signature').setup {
      floating_window_above_cur_line = true,
      hint_enable = false,
  }
end

return config
