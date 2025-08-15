"Enable line numbers
"set number
set relativenumber

set ignorecase
set smartcase

"set hlsearch
"nnoremap <Esc> :nohlsearch<CR><Esc>

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
nnoremap <F3> :set wrap!

set syntax=on
filetype plugin indent on

"set backspace=indent,eol,start

"set completeopt=menu,menuone,noselect

"shortmess=filnxtToO "default
