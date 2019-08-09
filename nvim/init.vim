let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'
set encoding=utf8

" Vim Plug{{{ 
  call plug#begin('~/.vim/plugged')
  Plug 'junegunn/fzf.vim'

  " Autocomplete
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  if !has('nvim')
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif

  " Git
  Plug 'airblade/vim-gitgutter'
  Plug 'chemzqm/vim-easygit'

  " Aspect
  Plug 'vim-airline/vim-airline'
  Plug 'ryanoasis/vim-devicons'
  Plug 'dylanaraps/wal.vim'
  Plug 'sheerun/vim-polyglot' 

  " Shortcuts
  Plug 'tpope/vim-commentary'
  Plug 'wellle/targets.vim'

  " Format
  Plug 'sbdchd/neoformat'
  
  " Note-taking
  Plug 'vimwiki/vimwiki'
  
  " Live reload files
  Plug 'djoshea/vim-autoread'

  " Vimfiler
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }

  " Languages
    " Ruby
    Plug 'takkii/Bignyanco'

    " HTML & CSS
    Plug 'mattn/emmet-vim'

    " Javascript in General 
    Plug 'mxw/vim-jsx' 
    Plug 'pangloss/vim-javascript'

    " Markdown
    function! BuildComposer(info)
      if a:info.status != 'unchanged' || a:info.force
        if has('nvim')
          !cargo build --release
        else
          !cargo build --release --no-default-features --features json-rpc
        endif
      endif
    endfunction

    Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer')}

" }}}
call plug#end()

" Source config files {{{
  set rtp+=/usr/local/opt/fzf
  source ~/.config/nvim/sources/configs.vim
  source ~/.config/nvim/sources/coc.vim
  source ~/.config/nvim/sources/keybindings.vim
  source ~/.config/nvim/sources/plug_configs.vim
  source ~/.config/nvim/lsp-configs/ruby.vim
" }}}
