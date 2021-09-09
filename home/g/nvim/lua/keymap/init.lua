local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
require('keymap.config')

local plug_map = {
    -- bufferline
    ["n|<A-l>"]          = map_cr("BufferPin"):with_noremap():with_silent(),
    ["n|<A-s>"]          = map_cr("BufferPick"):with_noremap():with_silent(),
    ["n|<A-d>"]          = map_cr("BufferOrderByDirectory"):with_noremap():with_silent(),
    ["n|<A-i>"]          = map_cr("BufferOrderByBufferNumber"):with_noremap():with_silent(),
    ["n|<A-n>"]          = map_cr("BufferNext"):with_noremap():with_silent(),
    ["n|<A-p>"]          = map_cr("BufferPrevious"):with_noremap():with_silent(),
    ["n|<A-N>"]          = map_cr("BufferMoveNext"):with_noremap():with_silent(),
    ["n|<A-P>"]          = map_cr("BufferMovePrevious"):with_noremap():with_silent(),
    ["n|<A-1>"]          = map_cr("BufferGoto 1"):with_noremap():with_silent(),
    ["n|<A-2>"]          = map_cr("BufferGoto 2"):with_noremap():with_silent(),
    ["n|<A-3>"]          = map_cr("BufferGoto 3"):with_noremap():with_silent(),
    ["n|<A-4>"]          = map_cr("BufferGoto 4"):with_noremap():with_silent(),
    ["n|<A-5>"]          = map_cr("BufferGoto 5"):with_noremap():with_silent(),
    ["n|<A-6>"]          = map_cr("BufferGoto 6"):with_noremap():with_silent(),
    ["n|<A-7>"]          = map_cr("BufferGoto 7"):with_noremap():with_silent(),
    ["n|<A-8>"]          = map_cr("BufferGoto 8"):with_noremap():with_silent(),
    ["n|<A-9>"]          = map_cr("BufferGoto 9"):with_noremap():with_silent(),
    ["n|<A-0>"]          = map_cr("BufferLast"):with_noremap():with_silent(),
    -- coq
    ["n|<C-b>"]          = map_cmd("<cmd>lua COQnav_mark()<CR>"):with_noremap():with_silent(),
    ["i|<C-b>"]          = map_cmd("<cmd>lua COQnav_mark()<CR>"):with_noremap():with_silent(),
    ["v|<C-b>"]          = map_cmd("<cmd>lua COQnav_mark()<CR>"):with_noremap():with_silent(),
    -- ctrlsf
    ["n|<leader>sf"]     = map_cmd("<Plug>CtrlSFPrompt"),
    -- Lsp mapp work when insertenter and lsp start
    ["n|<leader>li"]     = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
    ["n|<leader>ll"]     = map_cr("LspLog"):with_noremap():with_silent():with_nowait(),
    ["n|<leader>lr"]     = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
    ["n|<C-f>"]          = map_cmd("<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>"):with_silent():with_noremap():with_nowait(),
    ["n|<C-b>"]          = map_cmd("<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>"):with_silent():with_noremap():with_nowait(),
    ["n|]e"]             = map_cr('Lspsaga diagnostic_jump_next'):with_noremap():with_silent(),
    ["n|[e"]             = map_cr('Lspsaga diagnostic_jump_prev'):with_noremap():with_silent(),
    ["n|K"]              = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
    ["n|ga"]             = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
    ["v|ga"]             = map_cu("Lspsaga range_code_action"):with_noremap():with_silent(),
    ["n|gd"]             = map_cr('Lspsaga preview_definition'):with_noremap():with_silent(),
    ["n|gD"]             = map_cmd("<cmd>lua vim.lsp.buf.implementation()<CR>"):with_noremap():with_silent(),
    ["n|gs"]             = map_cr('Lspsaga signature_help'):with_noremap():with_silent(),
    ["n|gr"]             = map_cr('Lspsaga rename'):with_noremap():with_silent(),
    ["n|gh"]             = map_cr('Lspsaga lsp_finder'):with_noremap():with_silent(),
    ["n|gt"]             = map_cmd("<cmd>lua vim.lsp.buf.type_definition()<CR>"):with_noremap():with_silent(),
    ["n|<Leader>ce"]     = map_cr('Lspsaga show_line_diagnostics'):with_noremap():with_silent(),
    -- Plugin Floaterm
    ["n|<A-t>"]          = map_cu('Lspsaga open_floaterm'):with_noremap():with_silent(),
    ["t|<A-t>"]          = map_cu([[<C-\><C-n>:Lspsaga close_floaterm<CR>]]):with_noremap():with_silent(),
    -- Plugin Telescope
    ["n|<Leader>bb"]     = map_cu('Telescope buffers'):with_noremap():with_silent(),
    ["n|<Leader>fa"]     = map_cu('Telescope grep_string'):with_noremap():with_silent(),
    ["n|<Leader>fb"]     = map_cu('Telescope file_browser'):with_noremap():with_silent(),
    ["n|<Leader>ff"]     = map_cu('Telescope find_files'):with_noremap():with_silent(),
    ["n|<Leader>fg"]     = map_cu('Telescope git_files'):with_noremap():with_silent(),
    ["n|<Leader>fw"]     = map_cu('Telescope grep_string'):with_noremap():with_silent(),
    ["n|<Leader>fl"]     = map_cu('Telescope loclist'):with_noremap():with_silent(),
    ["n|<Leader>fc"]     = map_cu('Telescope git_commits'):with_noremap():with_silent(),
    ["n|<Leader>ft"]     = map_cu('Telescope help_tags'):with_noremap():with_silent(),
    ["n|<F2>"]           = map_cu('Telescope buffers'):with_noremap():with_silent(),
    ["i|<F2>"]           = map_cmd('<cmd>Telescope buffers<CR>'):with_noremap():with_silent(),
    ["v|<F2>"]           = map_cu('Telescope buffers'):with_noremap():with_silent(),
    ["n|<Leader>fo"]     = map_cu('Telescope find_files search_dirs=%:p:h'):with_noremap():with_silent(),
    -- prodoc
    ["n|gcc"]            = map_cu('ProComment'):with_noremap():with_silent(),
    ["x|gcc"]            = map_cr('ProComment'),
    ["n|gcj"]            = map_cu('ProDoc'):with_silent():with_silent(),
    -- Plugin acceleratedjk
    ["n|j"]              = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
    ["n|k"]              = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),
    -- Plugin Vista
    ["n|<Leader>v"]      = map_cu('Vista'):with_noremap():with_silent(),
    -- Plugin vim-operator-surround
    ["n|sa"]             = map_cmd("<Plug>(operator-surround-append)"):with_silent(),
    ["n|sd"]             = map_cmd("<Plug>(operator-surround-delete)"):with_silent(),
    ["n|sr"]             = map_cmd("<Plug>(operator-surround-replace)"):with_silent(),
    -- Hop
    ["n|<Leader> "]      = map_cr("HopChar2"):with_noremap():with_silent(),
    -- ISwap
    ["n|gw"]             = map_cr("ISwap"):with_noremap():with_silent(),
    -- Extra
    ["n|<Leader>e"]      = map_cmd(":e <c-r>=expand('%:p:h')<cr>/"):with_noremap(),
    ["n|<Leader>gg"]     = map_cmd(":lua require 'telescope.builtin'.grep_string({ search = vim.fn.input(\"Grep For > \")})<CR>"):with_noremap():with_silent(),
    ["n|<Leader>/"]     = map_cmd(':nohl<CR>'):with_noremap():with_silent(),
};

bind.nvim_load_mapping(plug_map)
