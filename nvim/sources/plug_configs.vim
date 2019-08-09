" EasyGrep {{{
  let g:EasyGrepCommand = 1
" }}}

" Airline {{{
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_powerline_fonts = 1
" }}}

" JSX {{{
  let g:jsx_ext_required = 0 " Allow JSX in normal JS files
" }}}

" VimwikiLinkHandler {{{
  function! VimwikiLinkHandler(link)
    let link = a:link
    if link =~# '^vfile:'
      let link = link[1:]
    else
      return 0
    endif
    let link_infos = vimwiki#base#resolve_link(link)
    if link_infos.filename == ''
      echomsg 'Vimwiki Error: Unable to resolve link!'
      return 0
    else
      exe 'tabnew ' . (link_infos.filename)
      return 1
    endif
  endfunction
" }}}
"
" fzf.vim {{{ 
" This is the default extra key bindings
  let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
  let g:fzf_layout = { 'down': '~40%' }

" In Neovim, you can set up fzf window using a Vim command
  let g:fzf_layout = { 'window': 'enew' }
  let g:fzf_layout = { 'window': '-tabnew' }
  let g:fzf_layout = { 'window': '10split enew' }

" Customize fzf colors to match your color scheme
  let g:fzf_colors =
  \ { 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
  let g:fzf_history_dir = '~/.local/share/fzf-history'
" }}} 

" Easy Git {{{
  let g:easygit_enable_command = 1
" }}}
