let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'
set encoding=utf8

set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim " path to dein.vim
" Dein {{{ 
  call dein#begin(expand('~/.vim/dein/repos/github.com/Shougo')) " plugins' root path
  call dein#add('Shougo/dein.vim')
  call dein#add('Shougo/unite.vim')
  
  " Autocomplete
  call dein#add('Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'})
  
  " Git
  call dein#add('airblade/vim-gitgutter')
  call dein#add('tpope/vim-fugitive')

  " Aspect
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('ryanoasis/vim-devicons')
  call dein#add('KeitaNakamura/highlighter.nvim')
  call dein#add('dylanaraps/wal.vim')

  " Shortcuts
  call dein#add('jiangmiao/auto-pairs')
  call dein#add('tpope/vim-surround')
  call dein#add('godlygeek/tabular')
  call dein#add('tpope/vim-commentary')
  
  " Navigation 
  call dein#add('ctrlpvim/ctrlp.vim')
  call dein#add('scrooloose/nerdtree',
      \{'on_cmd': 'NERDTreeToggle'})
  call dein#add('dkprice/vim-easygrep')
  
  " Linting 
  call dein#add('w0rp/ale')

  " Live reload files
  call dein#add('djoshea/vim-autoread')

  " Languages
    " Ruby
    call dein#add('vim-ruby/vim-ruby')
    call dein#add('tpope/vim-rails')
    
    " C Family
    call dein#add('zchee/deoplete-clang')
    call dein#add('beyondmarc/opengl.vim')

    " Python
    call dein#add('zchee/deoplete-jedi')

    " LaTeX
    call dein#add('donRaphaco/neotex', {'for': 'tex'})

    " HTML & CSS
    call dein#add('mattn/emmet-vim')

    " Go 
    call dein#add('fatih/vim-go') 

    " React
    call dein#add('mxw/vim-jsx') 

" }}}
call dein#end()

" {{{
set nocompatible
set showmatch           " Show matching brackets.
set showcmd
set visualbell
set number              " Show the line numbers on the left side.
set relativenumber 
set formatoptions+=o    " Continue comment marker in new lines.
set textwidth=0         " Hard-wrap long lines as you type them.
set tabstop=4           " Render TABs using this many spaces.
set shiftwidth=4        " Indentation amount for < and > commands.
set expandtab
set splitbelow
set splitright
set smarttab autoindent
set lazyredraw
set showcmd
set grepprg=rg\ --vimgrep
set incsearch
set hlsearch
filetype plugin on
syntax on
" }}}
" Keymappings
let mapleader=','
let g:mapleader=','
inoremap jj <esc>           " Natural Esc
nnoremap <leader>w :w<CR>   " Natural Save
nnoremap <leader>x :x<CR>   " Natural Force-Quit
nnoremap <leader>q :q<CR>   " Natural Quit

"No Higlight
nnoremap <Leader>h :noh<CR> 

" Split Navigation
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

" NERDTree mappings {{{
map <C-n> :NERDTreeToggle<CR>
" }}}

set linespace=0         " Set line-spacing to minimum.
set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
" More natural splits
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

if !&scrolloff
set scrolloff=3       " Show next 3 lines while scrolling.
endif
if !&sidescrolloff
set sidescrolloff=5   " Show next 5 columns while side-scrolling.
endif
set nostartofline       " Do not jump to first character with page commands.

" Colorscheme
set background=dark
colorscheme wal
 
" NERDTree {{{
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.pyc$', '__pycache__','\.class$']
" }}}

" EasyGrep {{{
  let g:EasyGrepCommand = 1
" }}}

" Airline {{{
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_powerline_fonts = 1
" }}}

" Devicons {{{ 
  set guifont=Monaco\Font:h11
  let g:webdevicons_enable = 1
  let g:webdevicons_enable_nerdtree = 1
  let g:webdevicons_enable_airline_tabline = 1
  let g:webdevicons_enable_airline_statusline = 1
  let g:webdevicons_enable_ctrlp = 1
" }}}

" AutoPairs {{{ 
  let g:AutoPairsFlyMode = 0
  let g:AutoPairsShortcutBackInsert = '<M-b>'
" }}}

" Deoplete {{{
  let g:deoplete#enable_at_startup = 1 
  " Deoplete-clang {{{
      let g:deoplete#sources#clang#libclang_path='/usr/local/Cellar/llvm@3.8/3.8.1/lib/llvm-3.8/lib/libclang.dylib'
      let g:deoplete#sources#clang#clang_header='/usr/local/Cellar/llvm@3.8/3.8.1/lib/llvm-3.8/include/clang'
  " }}}
   
" }}}
