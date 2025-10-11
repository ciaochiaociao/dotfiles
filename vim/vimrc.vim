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
