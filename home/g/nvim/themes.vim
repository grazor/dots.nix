" Theme stuff
" Dynamically switch color scheme and have things respect it

syntax enable
let g:airline_theme='oceanicnext'
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE
hi SignColumn guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE
colorscheme OceanicNext

nnoremap <silent> <C-c><C-y> :call ToggleConcealLevel()<CR>

" Conceal
syntax match pyNiceOperator "<=" conceal cchar=≤
syntax match pyNiceOperator ">=" conceal cchar=≥
syntax match pyNiceOperator "=\@<!===\@!" conceal cchar=≡
syntax match pyNiceOperator "!=" conceal cchar=≢

syntax match pyNiceOperator " \* " conceal cchar=∙
syntax match pyNiceOperator " / " conceal cchar=÷
" The following are special cases where it /may/ be okay to ignore PEP8
syntax match pyNiceOperator "\( \|\)\*\*\( \|\)2\>" conceal cchar=²
syntax match pyNiceOperator "\( \|\)\*\*\( \|\)3\>" conceal cchar=³
syntax match pyNiceOperator "\( \|\)\*\*\( \|\)n\>" conceal cchar=ⁿ

syntax keyword pyNiceStatement lambda conceal cchar=λ
syntax keyword pyNiceStatement sum conceal cchar=∑

highlight link pyNiceStatement Keyword

set conceallevel=2
let g:indentLine_conceallevel = 2
set concealcursor=nvc
let g:indentLine_concealcursor = 'nvc'
