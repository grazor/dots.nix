set number
set relativenumber
set cursorline
set wrap
set linebreak
set showmatch
set noshowmode
set showtabline=1

set showbreak=↪\ 
set listchars=eol:¬,extends:❯,precedes:❮

let g:indentLine_char = '▏'

let g:lens#disabled_filetypes = ['nerdtree', 'fzf']
let g:lens#width_resize_min = 120
let g:lens#width_resize_max = 140
let g:lens#height_resize_min = 10
let g:lens#height_resize_max = 30

highlight ColorColumn ctermbg=0 guibg=#001122

"autocmd BufNewFile,BufRead *.go SemanticHighlightToggle
nnoremap <Leader>l :SemanticHighlightToggle<cr>


set scrolloff=999
