call plug#begin('~/.local/share/nvim/plugged')

" Coding general
"Plug 'neoclide/coc.nvim', {'do': './install.sh nightly'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ludovicchabant/vim-gutentags'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-endwise'
"Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'majutsushi/tagbar'
Plug 'Yggdroot/indentLine'
Plug 'markonm/traces.vim'
Plug 'vimwiki/vimwiki'
"Plug 'PeterRincker/vim-argumentative'
Plug 'AndrewRadev/sideways.vim'
Plug 'kshenoy/vim-signature'
Plug 'caenrique/nvim-toggle-terminal'

" Visual
"Plug 'camspiers/animate.vim'
Plug 'camspiers/lens.vim'
"Plug 'blueyed/vim-diminactive'
Plug 'jaxbot/semantic-highlight.vim'

" Python
Plug 'mgedmin/python-imports.vim'

" Filesystem
Plug 'tpope/vim-eunuch'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'


" Editing
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'yuttie/comfortable-motion.vim'
Plug 'bkad/CamelCaseMotion'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular'


" VCS
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'tpope/vim-rhubarb'


" Modeline
Plug 'itchyny/lightline.vim'
Plug 'itchyny/calendar.vim'
Plug 'sainnhe/artify.vim'
Plug 'macthecadillac/lightline-gitdiff'
Plug 'ryanoasis/vim-devicons'


" Themes
Plug 'challenger-deep-theme/vim', {'name': 'challenger-deep'}
Plug 'haishanh/night-owl.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'mhartington/oceanic-next'

call plug#end()
