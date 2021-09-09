local config = {}

function config.galaxyline()
  require('modules.ui.eviline')
end

function config.indent_blakline()
    require("indent_blankline").setup {
        space_char_blankline = " ",
        show_current_context = true,
        context_patterns = {
            "class",
            "function",
            "method",
            "block",
            "list_literal",
            "selector",
            "^if",
            "case",
            "^table",
            "if_statement",
            "while",
            "for"
        },
    }
end

function config.gitsigns()
    if not packer_plugins['plenary.nvim'].loaded then
        vim.cmd [[packadd plenary.nvim]]
    end
    require('gitsigns').setup {
        signs = {
            add = {hl = 'GitGutterAdd', text = '▋'},
            change = {hl = 'GitGutterChange',text= '▋'},
            delete = {hl= 'GitGutterDelete', text = '▋'},
            topdelete = {hl ='GitGutterDeleteChange',text = '▔'},
            changedelete = {hl = 'GitGutterChange', text = '▎'},
        }
    }
end

return config
