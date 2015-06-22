syntax on

set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab
set incsearch
set visualbell
set autoindent

:set showmatch
:set whichwrap=b,s,h,l
set vb
set ignorecase
set incsearch

" This block maps the 'q' key to format a paragraph.
set shell=/bin/csh redraw
map K !} fmt -72 -c
map U !} fmt -72 -c
"map q K}

set tw=0

" Map F8 to write the file.
map <F8> :w

set synmaxcol=40000

execute pathogen#infect()
syntax on
filetype plugin indent on

let g:syntastic_python_checkers = ['pyflakes']
let g:syntastic_check_on_open=1

highlight SyntasticError   ctermfg=red
highlight SyntasticWarning ctermbg=lightgrey

au FileType haskell nnoremap <buffer> <F4> :GhcImportedFromOpenHaddock<CR>
au FileType lhaskell nnoremap <buffer> <F4> :GhcImportedFromOpenHaddock<CR>

au FileType haskell nnoremap <buffer> <F5> :GhcImportedFromEchoUrl<CR>
au FileType lhaskell nnoremap <buffer> <F5> :GhcImportedFromEchoUrl<CR>

au FileType haskell  vnoremap <S-F4> :<C-u> :GhcImportedFromOpenHaddockVismode<CR>
au FileType lhaskell vnoremap <S-F4> :<C-u> :GhcImportedFromOpenHaddockVismode<CR>

au FileType haskell  vnoremap <S-F5> :<C-u> :GhcImportedFromEchoUrlVismode<CR>
au FileType lhaskell vnoremap <S-F5> :<C-u> :GhcImportedFromEchoUrlVismode<CR>

au FileType haskell nnoremap <buffer> <F1> :GhcModType<CR>
au FileType haskell nnoremap <buffer> <F2> :GhcModInfo<CR>
au FileType haskell nnoremap <buffer> <silent> <F3> :GhcModTypeClear<CR>

au FileType lhaskell nnoremap <buffer> <F1> :GhcModType<CR>
au FileType lhaskell nnoremap <buffer> <F2> :GhcModInfo<CR>
au FileType lhaskell nnoremap <buffer> <silent> <F3> :GhcModTypeClear<CR>

let g:ghcimportedfrom_browser = '/usr/bin/google-chrome'

autocmd BufWritePost *.hs  GhcModCheckAsync
autocmd BufWritePost *.lhs GhcModCheckAsync

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Bind Ctrl-e to toggle the error list. Bliss.
" http://stackoverflow.com/questions/17512794/toggle-error-location-panel-in-syntastic
function! ToggleErrors()
    let old_last_winnr = winnr('$')
    lclose
    if old_last_winnr == winnr('$')
        " Nothing was closed, open syntastic error location panel
        Errors
    endif
endfunction

nnoremap <silent> <C-e> :<C-u>call ToggleErrors()<CR>

let g:vim_markdown_folding_disabled=1

let g:necoghc_debug=1
