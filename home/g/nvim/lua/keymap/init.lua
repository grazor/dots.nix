local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
require('keymap.config')

local plug_map = {
  ["i|jk"] = map_cmd('<ESC>'):with_silent():with_noremap(),
  ["n|<leader>/"] = map_cr('nohl'):with_silent():with_noremap(),
  ["n|<leader>e"] = map_cmd(":e <c-r>=expand('%:p:h')<cr>/"):with_noremap(),

  -- Packer
  ["n|<leader>pu"] = map_cr("PackerUpdate"):with_silent():with_noremap()
    :with_nowait(),
  ["n|<leader>pi"] = map_cr("PackerInstall"):with_silent():with_noremap()
    :with_nowait(),
  ["n|<leader>pc"] = map_cr("PackerCompile"):with_silent():with_noremap()
    :with_nowait(),

  -- Plugin acceleratedjk
  ["n|j"] = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
  ["n|k"] = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),

  -- trevJ
  ["n|<leader>j"] = map_cmd("<cmd>lua require('trevj').format_at_cursor()<CR>"):with_noremap()
    :with_silent(),

  -- Plugin Telescope
  ["n|<F2>"] = map_cu('Telescope buffers'):with_noremap():with_silent(),
  ["n|<leader>bb"] = map_cu('Telescope buffers'):with_noremap():with_silent(),
  ["n|<leader>ff"] = map_cu('Telescope git_files'):with_noremap():with_silent(),
  ["n|<leader>fw"] = map_cu('Telescope grep_string'):with_noremap()
    :with_silent(),
  ["n|<leader>fa"] = map_cu('Telescope grep_string search=""'):with_noremap()
    :with_silent(),
  ["n|<leader>fo"] = map_cu('Telescope find_files search_dirs=%:p:h'):with_noremap()
    :with_silent(),

  -- Lsp mapp work when insertenter and lsp start
  ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent()
    :with_nowait(),
  ["n|<leader>ll"] = map_cr("LspLog"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent()
    :with_nowait(),
  ["n|<C-f>"] = map_cmd(
    "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>"):with_silent()
    :with_noremap():with_nowait(),
  ["n|<C-b>"] = map_cmd(
    "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>"):with_silent()
    :with_noremap():with_nowait(),
  ["n|[e"] = map_cr('Lspsaga diagnostic_jump_next'):with_noremap():with_silent(),
  ["n|]e"] = map_cr('Lspsaga diagnostic_jump_prev'):with_noremap():with_silent(),
  ["n|K"] = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
  ["n|ga"] = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
  ["v|ga"] = map_cu("Lspsaga range_code_action"):with_noremap():with_silent(),
  ["n|go"] = map_cr('Lspsaga preview_definition'):with_noremap():with_silent(),
  ["n|gD"] = map_cmd("<cmd>lua vim.lsp.buf.implementation()<CR>"):with_noremap()
    :with_silent(),
  ["n|gs"] = map_cr('Lspsaga signature_help'):with_noremap():with_silent(),
  ["n|gr"] = map_cr('Lspsaga rename'):with_noremap():with_silent(),
  ["n|gh"] = map_cr('Lspsaga lsp_finder'):with_noremap():with_silent(),
  ["n|gt"] = map_cmd("<cmd>lua vim.lsp.buf.type_definition()<CR>"):with_noremap()
    :with_silent(),

  -- Plugin surfer
  ["x|J"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("next", "visual")<cr>'):with_noremap()
    :with_silent(),
  ["x|K"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual")<cr>'):with_noremap()
    :with_silent(),
  ["x|H"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("parent", "visual")<cr>'):with_noremap()
    :with_silent(),
  ["x|L"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("child", "visual")<cr>'):with_noremap()
    :with_silent(),
  ["x|<A-j>"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("next", "visual", true)<cr>'):with_noremap()
    :with_silent(),
  ["x|<A-k>"] = map_cmd(
    '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual", true)<cr>'):with_noremap()
    :with_silent(),
};

--[[
    -- Plugin Telescope
    --["n|<leader>fl"]     = map_cu('Telescope loclist'):with_noremap():with_silent(),
    --["n|<leader>fc"]     = map_cu('Telescope git_commits'):with_noremap():with_silent(),
    --["n|<leader>ft"]     = map_cu('Telescope help_tags'):with_noremap():with_silent(),
    --["n|<leader>fd"]     = map_cu('Telescope dotfiles path='..os.getenv("HOME")..'/.dotfiles'):with_noremap():with_silent(),
    --["n|<leader>fb"]     = map_cu('Telescope file_browser'):with_noremap():with_silent(),

    ["i|<TAB>"]      = map_cmd('v:lua.tab_complete()'):with_expr():with_silent(),
    ["i|<S-TAB>"]    = map_cmd('v:lua.s_tab_complete()'):with_silent():with_expr(),
--["i|<CR>"]       = map_cmd([compe#confirm({ 'keys': "\<Plug>delimitMateCR", 'mode': '' })]):with_noremap():with_expr():with_nowait(),
    -- person keymap
    ["n|gb"]             = map_cr("BufferLinePick"):with_noremap():with_silent(),
    ["n|<leader>tf"]     = map_cu('DashboardNewFile'):with_noremap():with_silent(),
    -- Plugin nvim-tree
    ["n|<leader>e"]      = map_cr('NvimTreeToggle'):with_noremap():with_silent(),
    ["n|<leader>F"]      = map_cr('NvimTreeFindFile'):with_noremap():with_silent(),
    -- Plugin MarkdownPreview
    ["n|<leader>om"]     = map_cu('MarkdownPreview'):with_noremap():with_silent(),
    -- Plugin DadbodUI
    ["n|<leader>od"]     = map_cr('DBUIToggle'):with_noremap():with_silent(),
    -- Plugin Floaterm
    ["n|<A-d>"]          = map_cu('Lspsaga open_floaterm'):with_noremap():with_silent(),
--["t|<A-d>"]          = map_cu([<C-\><C-n>:Lspsaga close_floaterm<CR>]):with_noremap():with_silent(),
    ["n|<leader>g"]      = map_cu("Lspsaga open_floaterm lazygit"):with_noremap():with_silent(),
    -- Far.vim
    ["n|<leader>fz"]     = map_cr('Farf'):with_noremap():with_silent();
    ["v|<leader>fz"]     = map_cr('Farf'):with_noremap():with_silent();
    -- prodoc
    ["n|gcc"]            = map_cu('ProComment'):with_noremap():with_silent(),
    ["x|gcc"]            = map_cr('ProComment'),
    ["n|gcj"]            = map_cu('ProDoc'):with_silent():with_silent(),
    -- Plugin QuickRun
    -- Plugin Vista
    ["n|<leader>v"]      = map_cu('Vista'):with_noremap():with_silent(),
    -- Plugin vim-operator-surround
    ["n|sa"]             = map_cmd("<Plug>(operator-surround-append)"):with_silent(),
    ["n|sd"]             = map_cmd("<Plug>(operator-surround-delete)"):with_silent(),
    ["n|sr"]             = map_cmd("<Plug>(operator-surround-replace)"):with_silent(),
};
--]]

bind.nvim_load_mapping(plug_map)
