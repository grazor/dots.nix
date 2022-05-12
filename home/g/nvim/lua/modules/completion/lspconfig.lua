local api = vim.api
local global = require 'core.global'
local format = require('modules.completion.format')

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                   .protocol
                                                                   .make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
require('lspconfig')['gopls'].setup {capabilities = capabilities}

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd [[edit]]
end

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

vim.cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
vim.cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')

vim.lsp.handlers['textDocument/publishDiagnostics'] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    -- Enable underline, use default values
    underline = true,
    -- Enable virtual text, override spacing to 4
    virtual_text = true,
    signs = {enable = true, priority = 20},
    -- Disable a feature
    update_in_insert = false,
  })

local enhance_attach = function(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    format.lsp_before_save()
  end
  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

