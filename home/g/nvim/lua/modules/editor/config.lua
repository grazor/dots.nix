local config = {}

function gitsigns_blame_formatter(name, blame_info, opts)
    if blame_info.author == name then
        blame_info.author = 'You'
    end

    local text
    if blame_info.author == 'Not Committed Yet' then
        text = blame_info.author
    else
        local date_time
        date_time = require('gitsigns.util').get_relative_time(tonumber(blame_info['author_time']))
        text = string.format('%s, %s - %s', blame_info.author, date_time, blame_info.summary)
    end

    local ffi = require("ffi")
    ffi.cdef'int curwin_col_off(void);'
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local len = vim.fn.virtcol('$')-1
    local width = vim.api.nvim_win_get_width(0) - ffi.C.curwin_col_off()
    local available_space = math.max(0, width - len)

    if available_space == 0 then
        text = ''
    elseif #text > available_space then
        text = text:sub(1, available_space-1)
    end

    return {{text, 'GitSignsCurrentLineBlame'}}
end

function config.gitsigns()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end

  require('gitsigns').setup({
    current_line_blame = true,
    current_line_blame_opts = {virt_text_pos = 'right_align', delay = 0},
    current_line_blame_formatter = gitsigns_blame_formatter,
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
