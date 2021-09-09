local config = {}

function config.nvim_lsp()
  require('modules.completion.lspconfig')
end

function config.telescope()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
    vim.cmd [[packadd popup.nvim]]
  end
  require('telescope').setup {
    defaults = {
      layout_config = {prompt_position = "top"},
      sorting_strategy = 'ascending',
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
      file_ignore_patterns = { "node_modules", "vendor" },
    },
    extensions = { }
  }
end

function config.smart_input()
  require('smartinput').setup {
    ['go'] = { ';',':=',';' }
  }
end

function config.vim_cursorwod()
   vim.api.nvim_command('augroup user_plugin_cursorword')
   vim.api.nvim_command('autocmd!')
   vim.api.nvim_command('autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0')
   vim.api.nvim_command('autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif')
   vim.api.nvim_command('autocmd InsertEnter * let b:cursorword = 0')
   vim.api.nvim_command('autocmd InsertLeave * let b:cursorword = 1')
   vim.api.nvim_command('augroup END')
end

return config
