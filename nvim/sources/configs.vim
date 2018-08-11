" Configurations {{{

set nocompatible
set showmatch           " Show matching brackets.
set showcmd
set number              " Show the line numbers on the left side.
set relativenumber      " Show numbers relative to the  current line
set formatoptions+=o    " Continue comment marker in new lines.
set textwidth=0         " Hard-wrap long lines as you type them.
set tabstop=2           " Render TABs using this many spaces.
set shiftwidth=2        " Indentation amount for < and > commands.
set expandtab
set splitbelow
set splitright
set smarttab autoindent
set lazyredraw
set showcmd
set grepprg=rg\ --vimgrep
set incsearch
set hlsearch
set autowrite         " Autowrite files
filetype plugin on
set linespace=0         " Set line-spacing to minimum.
set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

" }}}

" Colorscheme
set background=dark
colorscheme wal
