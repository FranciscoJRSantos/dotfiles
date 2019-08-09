" Keymappings {{{
  let g:mapleader=','
  inoremap jj <esc>               " Natural Esc
  nnoremap <leader>w :w<CR>       " Natural Save
  nnoremap <leader>x :x<CR>       " Natural Force-Quit
  nnoremap <leader>q :q<CR>       " Natural Quit
" }}}

" No Higlight
  nnoremap <leader><space> :nohlsearch<CR> 

" Split {{{
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>
  nnoremap <C-=> <C-W><S-=>
" }}}

" Clipboard keymappings {{{
  vnoremap <leader>y "+y
  vnoremap <leader>d "+d
  nnoremap <leader>p "+p
  nnoremap <leader>P "+P
  vnoremap <leader>p "+p
  vnoremap <leader>P "+P
" }}}

" Function keymappings
  nnoremap <F8> :let _s=@/<Bar>:%s/;\s\+$/;/e<Bar>:let @/=_s<Bar><CR>

" Explore {{{ 
  nnoremap <leader>e :Explore<CR>
" }}}

" Neosnippet {{{
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
  let g:neosnippet#enable_snipmate_compatibility = 1
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)

  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" }}}

" Fzf.vim {{{
" Mapping selecting mappings
  nmap <leader><tab> <plug>(fzf-maps-n)
  xmap <leader><tab> <plug>(fzf-maps-x)
  omap <leader><tab> <plug>(fzf-maps-o)

  nnoremap <silent> <Leader><Leader> :Files<CR>
  nnoremap <silent> <Leader><Enter> :Buffers<CR>
" }}}
