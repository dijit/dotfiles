if &t_Co != 256 && ! has("gui_running")
  echomsg ""
  echomsg "err: please use GUI or a 256-color terminal (so that t_Co=256 could be set)"
  echomsg ""
  finish
endif
set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let colors_name = "monoprint"
" --- Definitions --- "
"" General colors
hi Normal       ctermfg=0 guifg=#000000 ctermbg=15  guibg=#ffffff cterm=none gui=none
hi clear CursorColumn
hi clear CursorLine
hi Folded       ctermfg=0  guifg=#000000 ctermbg=0  guibg=#ffffff  cterm=bold  gui=bold
hi NonText      ctermfg=bg guifg=bg
hi SpecialKey   ctermfg=bg guifg=bg
"" Syntax highlighting
hi Comment      ctermfg=247 guifg=#9e9e9e cterm=italic gui=italic
hi Constant     ctermfg=234 guifg=#1c1c1c cterm=bold gui=bold
hi clear Error
hi Error        ctermfg=234 guifg=#1c1c1c ctermbg=253 guibg=#dadada cterm=undercurl  gui=undercurl
hi clear ErrorMsg
hi ErrorMsg     ctermfg=234 guifg=#1c1c1c ctermbg=253 guibg=#dadada cterm=undercurl  gui=undercurl
hi clear WarningMsg
hi WarningMsg   ctermfg=234 guifg=#1c1c1c ctermbg=253 guibg=#dadada
hi Identifier   ctermfg=237 guifg=#3a3a3a
hi Ignore       ctermfg=238 guifg=#444444
hi LineNr       ctermfg=247 guifg=#9e9e9e
hi clear MatchParen
hi Number       ctermfg=243 guifg=#767676
hi PreProc      ctermfg=247 guifg=#9e9e9e cterm=bold gui=bold
hi Special      ctermfg=247 guifg=#9e9e9e cterm=bold gui=bold
hi Statement    ctermfg=234 guifg=#1c1c1c cterm=bold gui=bold
hi Todo         ctermfg=255 guifg=#ffffff ctermbg=235 guibg=#262626 cterm=bold gui=bold
hi Type         ctermfg=242 guifg=#666666 cterm=bold gui=bold
hi clear Underlined
hi Underlined   cterm=underline gui=underline
hi clear Title
hi Title        ctermfg=239 guifg=#4e4e4e cterm=bold,underline gui=bold,underline
