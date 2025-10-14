set nocompatible
filetype plugin indent on
syntax on

"Enable line numbers
set number
set relativenumber

"show search statistics messages
set shortmess-=S

set ignorecase
set smartcase

set hlsearch
"nnoremap <Esc> :nohlsearch<CR>

"set showmatch

"Allow switching buffers without saving
"set hidden


inoremap jk <Esc>
inoremap kj <Esc>
set timeoutlen=300

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

set expandtab
set smarttab
set tabstop=4
set shiftwidth=4

set autoindent
"set smartindent " mainly for C/C++, Java, etc.


"set mouse
nnoremap <F2> :if &mouse == 'a' \| set mouse= \| else \| set mouse=a \| endif<CR>

nnoremap <F3> :set wrap!<CR>
nnoremap <F4> :set relativenumber! number!<CR>
"set backspace=indent,eol,start


"shortmess=filnxtToO "default

"for file searching
set path+=**

"autocompletion
set wildmenu
set wildignore+=*.o,*.obj,*.pyc,*.git,*.swp
"set wildmode=longest:full:full
set completeopt=menu,menuone  " selectone is only available for neovim

"terminal mode
tnoremap <Esc> <C-\><C-n>
"nnoremap <leader>t :belowright split | resize 12 | term<CR>

" FZF basic keymaps
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :Helptags<CR>

" netrw
" --- Make netrw a persistent sidebar ---
"let g:netrw_banner = 0            " Disable the top help banner
let g:netrw_liststyle = 3         " Tree-style listing
let g:netrw_browse_split = 4      " Open files in previous window
"let g:netrw_altv = 1              " Split to the left
let g:netrw_winsize = 25          " Sidebar width
"let g:netrw_preview = 1           " Use preview window if available

" Optional: open netrw automatically on startup if no file given
autocmd VimEnter * if argc() == 0 | Vexplore | wincmd l | endif
nnoremap <silent> <leader>e :Lexplore<CR>

" Theme
set background=dark
colorscheme gruvbox

" status bar: lightline
let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ }

" startify
let g:startify_lists = [
  \ { 'type': 'files',     'header': ['   Recent Files'] },
  \ { 'type': 'sessions',  'header': ['   Sessions'] },
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks'] },
  \ { 'type': 'commands',  'header': ['   Commands'] },
  \ ]
let g:startify_bookmarks = [ '~/.vimrc', '/data/ap5/users/chiahsu/', '/data/ap5/users/chiahsu/trip3_snr']
let g:startify_session_dir = '~/.vim/session'

" syntax
let g:python_highlight_all = 1

" disable clipboard to make remote CLI vim faster
" set clipboard=
" OSC-52
if has("clipboard")
  set clipboard=unnamedplus
endif

if executable('osc52.sh')
  let g:clipboard = {
        \ 'name': 'OSC52',
        \ 'copy': {
        \   '+': 'osc52.sh',
        \   '*': 'osc52.sh',
        \ },
        \ 'paste': {
        \   '+': 'pbpaste',
        \   '*': 'pbpaste',
        \ },
        \ }
endif
