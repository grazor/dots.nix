local config = {}

function config.gitsigns()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end

  require('gitsigns').setup({
    current_line_blame = true,
    current_line_blame_opts = {virt_text_pos = 'right_align', delay = 0},
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  })
end

function config.gitlinker()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end

  require('gitlinker').setup({
    callbacks = {
      ["stash.msk.avito.ru"] = function(url_data)
        local repo = vim.split(url_data.repo, "/")
        local url = "https://" .. url_data.host
        if url_data.port then url = url .. ":" .. url_data.port end
        url = url .. "/projects/" .. repo[1] .. "/repos/" .. repo[2]
        url = url .. "/browse/" .. url_data.file
        if url_data.lstart and url_data.lend then
          url = url .. "#" .. url_data.lstart .. "-" .. url_data.lend
        end
        return url
      end,
    },
  })
end

function config.autopairs()
  require('nvim-autopairs').setup {}

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp = require('cmp')
  cmp.event:on('confirm_done',
               cmp_autopairs.on_confirm_done({map_char = {tex = ''}}))
end

function config.trevj()
  if not packer_plugins['nvim-treesitter'].loaded then
    vim.cmd [[packadd nvim-treesitter]]
  end
  require("trevj").setup()
end

function config.cursorline()
  require('nvim-cursorline').setup {
    cursorline = {enable = false},
    cursorword = {enable = true, min_length = 3, hl = {underline = true}},
  }
end

function config.indent()
  vim.opt.list = true
  vim.opt.listchars:append("space:⋅")

  require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = false,
  }
end

function config.neoscroll()
  require('neoscroll').setup({
    mappings = {
      '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb',
    },
  })
end

function config.mini()
  require('mini.surround').setup {}
  require('mini.comment').setup {}
end

return config
