set nocompatible
set rtp+=~/.vim/bundle/Vundle.vim
set encoding=utf-8

"Vundle Stuff {{
call vundle#begin()
  Plugin 'gmarik/Vundle.vim'
  Plugin 'bling/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  Plugin 'scrooloose/nerdtree'
  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'tpope/vim-surround'
  Plugin 'jiangmiao/auto-pairs'
  Plugin 'airblade/vim-gitgutter'
  Plugin 'mattn/emmet-vim'
  Plugin 'shougo/neocomplete.vim'
  Plugin 'tpope/vim-rails'
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'tpope/vim-fugitive'
  Plugin 'dylanaraps/wal.vim'
call vundle#end()

" Basic setup
let mapleader="\<SPACE>"
set showmatch           " Show matching brackets.
set showcmd
set number              " Show the line numbers on the left side.
set formatoptions+=o    " Continue comment marker in new lines.
set textwidth=0         " Hard-wrap long lines as you type them.
set expandtab           " Insert spaces when TAB is pressed.
set tabstop=4          " Render TABs using this many spaces.
set shiftwidth=2        " Indentation amount for < and > commands.
set splitbelow
set splitright
set showcmd
set smarttab autoindent
set lazyredraw
set ttyfast
set showcmd
syntax on

colorscheme wal

" Keymappings
inoremap jj <esc>       " Natural esc
nmap <leader>w :w<CR>
nmap <leader>x :x<CR>
nmap <leader>q :q<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nmap <leader>r <C-R>
" Clipboard keymappings
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

"Mapping for vim-expand-region {{
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
"}}

