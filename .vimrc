" Setting basic preferences {{{
set foldmethod=marker
set nocindent
set nu
set nowrap
set autoindent
set shiftwidth=4 ts=4 et
set incsearch hlsearch
" }}}

" Settings for Programming {{{
" set smartindent
filetype plugin indent on
"" set mouse=hvi
syntax enable

" Highlight trailing whitespace and tabs
highlight link RedundantSpaces Error
au BufEnter,BufRead * match RedundantSpaces "\t"
au BufEnter,BufRead * match RedundantSpaces "[[:space:]]\+$"
"}}}

" Setting new Defaults {{{
" Set default sh to bash
let g:is_sh	   = 1

function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
" }}}

" Allow SUDO from inside vim add new preferences. {{{
"Will allow you to use :w!! to write to a file using sudo if you forgot to
""sudo vim file" (it will prompt for sudo password when writing)
cmap w!! %!sudo tee 2> /dev/null %

colorscheme zenburn

autocmd FileType python set omnifunc=pythoncomplete#Complete
"}}}

" GPG Stuff {{{

" nsparent editing of GnuPG-encrypted files
" Based on a solution by Wouter Hanegraaff
augroup encrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg,*.asc set viminfo=
  " We don't want a swap file, as it writes unencrypted data to disk.
  autocmd BufReadPre,FileReadPre *.gpg,*.asc set noswapfile
  " Switch to binary mode to read the encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg,*.asc let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost *.gpg,*.asc 
    \ '[,']!sh -c 'gpg --decrypt 2> /dev/null'
  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg,*.asc let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg,*.asc 
    \ execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  autocmd BufWritePre,FileWritePre *.gpg set bin 
  autocmd BufWritePre,FileWritePre *.gpg 
    \ '[,']!sh -c 'gpg --default-recipient-self -e 2>/dev/null'
  autocmd BufWritePre,FileWritePre *.asc 
    \ '[,']!sh -c 'gpg --default-recipient-self -e -a 2>/dev/null'
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg,*.asc u
augroup END

map ^E :1,$!gpg --armor --encrypt 2>/dev/null^M^L
map ^G :1,$!gpg --armor --encrypt --sign 2>/dev/null^M^L
map ^Y :1,$!gpg --clearsign 2>/dev/null^M^L

"" End GPG Stuff }}}

