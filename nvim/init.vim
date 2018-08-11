let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'
set encoding=utf8

set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim " path to dein.vim
" Dein {{{ 
  call dein#begin(expand('~/.vim/dein/repos/github.com/Shougo')) " plugins' root path
  call dein#add('Shougo/dein.vim')
  call dein#add('Shougo/unite.vim')
  call dein#add('junegunn/fzf.vim')
  
  " Autocomplete
  call dein#add('Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'})
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  " Git
  call dein#add('airblade/vim-gitgutter')
  call dein#add('chemzqm/vim-easygit')
  " call dein#add('chemzqm/denite-git')

  " Aspect
  call dein#add('vim-airline/vim-airline')
  call dein#add('ryanoasis/vim-devicons')
  call dein#add('dylanaraps/wal.vim')
  call dein#add('sheerun/vim-polyglot') 

  " Shortcuts
  call dein#add('tpope/vim-commentary')
  call dein#add('wellle/targets.vim')

  " Format
  call dein#add('sbdchd/neoformat')
  
  " Navigation 
  " call dein#add('Shougo/denite.nvim')
  call dein#add('scrooloose/nerdtree',
      \{'on_cmd': 'NERDTreeToggle'})
  " call dein#add('sjl/gundo.vim')

  " Note-taking
  call dein#add('vimwiki/vimwiki')
  
  " Linting 
  call dein#add('w0rp/ale')
  call dein#add('prettier/vim-prettier', { 'do': 'yarn install' })

  " Focusing
  " call dein#add('reedes/vim-pencil')

  " Live reload files
  call dein#add('djoshea/vim-autoread')

  " Snippets
  call dein#add('SirVer/ultisnips')
  call dein#add('honza/vim-snippets')
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  " Languages
    " Ruby
    call dein#add('vim-ruby/vim-ruby')
    call dein#add('tpope/vim-rails')
    
    " C Family
    call dein#add('zchee/deoplete-clang')

    " Python
    call dein#add('zchee/deoplete-jedi')

    " LaTeX
    " call dein#add('donRaphaco/neotex', {'for': 'tex'})

    " HTML & CSS
    call dein#add('mattn/emmet-vim')

    " Javascript in General (Only gonna use it for React lmao)
    call dein#add('mxw/vim-jsx') 
    " call dein#add('flowtype/vim-flow') 
    call dein#add('pangloss/vim-javascript')

" }}}
call dein#end()

" Source config files {{{
  set rtp+=/usr/local/opt/fzf
  source ~/.config/nvim/sources/configs.vim
  source ~/.config/nvim/sources/keybindings.vim
  source ~/.config/nvim/sources/plug_configs.vim
" }}}
