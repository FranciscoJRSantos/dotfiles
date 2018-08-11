" Keymappings
let g:mapleader=','
inoremap jj <esc>               " Natural Esc
nnoremap <leader>w :w<CR>       " Natural Save
nnoremap <leader>x :x<CR>       " Natural Force-Quit
nnoremap <leader>q :q<CR>       " Natural Quit

"No Higlight
nnoremap <leader><space> :nohlsearch<CR> 

" Split Navigation {{{
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>
  nmap <leader>r <C-R>
" }}}

" Clipboard keymappings {{{
  vnoremap <Leader>y "+y
  vnoremap <Leader>d "+d
  nnoremap <Leader>p "+p
  nnoremap <Leader>P "+P
  vnoremap <Leader>p "+p
  vnoremap <Leader>P "+P
" }}}

" Function keymappings
  nnoremap <F8> :let _s=@/<Bar>:%s/;\s\+$/;/e<Bar>:let @/=_s<Bar><CR>

" NERDTree mappings {{{
  map <C-n> :NERDTreeToggle<CR>
" }}}

" Denite mappings {{{
  nnoremap <C-p> :<C-u>Denite file_rec<CR>
  nnoremap <leader>/ :<C-u>Denite grep:. -mode=normal<CR>
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
