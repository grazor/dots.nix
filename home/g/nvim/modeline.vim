source ~/.config/nvim/battery.vim
let g:battery#update_interval = 10000
call battery#watch()
function! BatteryLevel() abort
	if exists('g:battery')
      return "\uf580 " . g:battery
	endif
endfunction

function! FileNameWithIcon() abort
    return winwidth(0) > 70  ? " " . WebDevIconsGetFileTypeSymbol() . ' ' . expand('%:.') : '' 
endfunction

function! FileNameWithParent(f) abort
    if expand('%:t') ==# ''
        return expand('%:p:h:t')
    else
        return expand('%:p:h:t') . "/" . expand("%:t")
    endif
endfunction

function! Line_num() abort
    return string(line('.'))
endfunction

function! Active_tab_num(n) abort
    return " " . a:n . " \ue0bb"
endfunction

function! Inactive_tab_num(n) abort
  return " " . a:n . " \ue0bb "
endfunction

function! Col_num() abort
    return string(getcurpos()[2])
endfunction

function! Git_status() abort
    return get(g:,'coc_git_status','')
endfunction

function! StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})

    if get(info, 'error', 0)
        return "\uf46f"
    endif

    if get(info, 'warning', 0)
        return info['warning'] . "\uf421"
    endif

  return "\uf42e" 
endfunction

function! Time() abort
    return "\uf64f " . strftime("%H:%M")
endfunction

" Config
let g:lightline = {}

" Registered components
let g:lightline.tab_component_function = {
    \ 'artify_activetabnum': 'Active_tab_num',
    \ 'artify_inactivetabnum': 'Inactive_tab_num',
    \ 'artify_filename': 'lightline_tab_filename',
    \ 'filename': 'lightline#tab#filename',
    \ 'modified': 'lightline#tab#modified',
    \ 'readonly': 'lightline#tab#readonly',
    \ 'tabnum': 'lightline#tab#tabnum',
    \ 'filename_with_parent': 'FileNameWithParent'
    \ }

let g:lightline.component = {
    \ 'filename_with_icon': '%{FileNameWithIcon()}',
    \ 'git_status': '%{Git_status()}',
    \ 'status_diagnostic': '%{StatusDiagnostic()}',
    \ 'battery': '%{BatteryLevel()}',
    \ 'time': '%{Time()}',
    \ 'coc': '%{coc#status()}',
    \ }

let g:lightline.component_expand = { 'gitdiff': 'lightline#gitdiff#get' }

let g:lightline.component_function = {
    \ }

" Active components
let g:lightline.tab_component = {}
let g:lightline.active = { 
    \ 'left': [ ['git_status'], ['filename_with_icon', 'modified'], ['coc']],
    \ 'right': [ ['battery', 'time'], ['status_diagnostic', 'lineinfo'],  ]
    \ }

let g:lightline.tabline = {
    \ 'left': [ [ 'vim_logo', 'tabs' ] ],
    \ 'right': [ [ 'git_branch' ], [ 'gitdiff' ]]
    \ }
let g:lightline.tab = {
        \ 'active': ['artify_activetabnum', 'filename_with_parent'],
        \ 'inactive': ['artify_inactivetabnum', 'filename']
        \ }
