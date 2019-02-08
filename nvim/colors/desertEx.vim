" Vim color file
" Maintainer:   Mingbai <mbbill AT gmail DOT com>

" disable under win32 colsole
if has("win32") && !has("gui_running")
  finish
endif

set background=dark
if version > 580
  " no guarantees for version 5.8 and below, but this makes it stop
  " complaining
  hi clear
  if exists("syntax_on")
  syntax reset
  endif
endif
let g:colors_name="desertEx"

highlight Normal guifg=gray70 guibg=gray17 gui=none ctermfg=250 ctermbg=235 cterm=NONE


" highlight groups
highlight SignColumn guifg=gray guibg=gray17 gui=none ctermfg=250 ctermbg=235 cterm=NONE
highlight Cursor guifg=black guibg=yellow gui=NONE ctermfg=16 ctermbg=226 cterm=NONE
highlight DiffAdd guifg=black guibg=wheat1 ctermfg=16 ctermbg=223
highlight DiffChange guifg=black guibg=skyblue1 ctermfg=16 ctermbg=117
highlight DiffDelete guifg=black guibg=gray45 gui=NONE ctermfg=16 ctermbg=243 cterm=NONE
highlight DiffText guifg=black guibg=hotpink1 gui=NONE ctermfg=16 ctermbg=205 cterm=NONE
highlight ErrorMsg guifg=white guibg=red gui=NONE ctermfg=231 ctermbg=196 cterm=NONE
highlight FoldColumn guifg=tan guibg=gray30 gui=NONE ctermfg=180 ctermbg=239 cterm=NONE
highlight Folded guifg=darkslategray3 guibg=gray30 gui=NONE ctermfg=116 ctermbg=239 cterm=NONE
highlight IncSearch guifg=#b0ffff guibg=#2050d0 ctermfg=159 ctermbg=26
highlight LineNr guifg=burlywood3 guibg=gray20 gui=NONE ctermfg=180 cterm=NONE
highlight MatchParen guifg=yellow guibg=gray17 gui=bold ctermfg=51 cterm=bold
highlight ModeMsg guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight MoreMsg guifg=seagreen gui=NONE ctermfg=29 cterm=NONE
highlight NonText guifg=cyan guibg=gray20 gui=NONE ctermfg=51 ctermbg=236 cterm=NONE
highlight Pmenu guifg=white guibg=#445599 gui=NONE ctermfg=231 ctermbg=61 cterm=NONE
highlight PmenuSel guifg=#445599 guibg=gray ctermfg=61 ctermbg=250
highlight Question guifg=springgreen gui=NONE ctermfg=48 cterm=NONE
highlight Search guifg=white guibg=#445599 gui=NONE ctermfg=255 ctermbg=61 cterm=NONE
highlight SpecialKey guifg=gray30 gui=NONE ctermfg=240 cterm=NONE
highlight StatusLine guifg=black guibg=#c2bfa5 gui=bold ctermfg=16 ctermbg=144 cterm=bold
highlight StatusLineNC guifg=gray guibg=gray40 gui=NONE ctermfg=250 ctermbg=241 cterm=NONE
highlight Title guifg=indianred gui=NONE ctermfg=167 cterm=NONE
highlight VertSplit guifg=gray40 guibg=gray40 gui=NONE ctermfg=241 ctermbg=241 cterm=NONE
highlight Visual guifg=black guibg=#ffff78 gui=NONE ctermfg=235 ctermbg=215 cterm=NONE
highlight WarningMsg guifg=salmon gui=NONE ctermfg=210 cterm=NONE
highlight WildMenu guifg=gray guibg=gray17 gui=NONE ctermfg=250 ctermbg=235 cterm=NONE
highlight colorcolumn guibg=gray30 ctermbg=240
highlight TabLine guifg=black guibg=lightsalmon gui=bold
highlight TabLineFill guifg=gray guibg=lightsalmon
highlight TabLineSel guifg=lightsalmon guibg=gray17

" syntax highlighting groups
highlight Comment guifg=palegreen3 gui=NONE ctermfg=114 cterm=NONE
highlight Constant guifg=#ff7878 gui=NONE ctermfg=210 cterm=NONE
highlight Identifier guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight Function guifg=skyblue gui=NONE ctermfg=117 cterm=NONE
highlight Statement guifg=#fcd38d gui=none ctermfg=186 cterm=none
highlight PreProc guifg=palevioletred2 gui=NONE ctermfg=211 cterm=NONE
highlight Type guifg=lightsalmon gui=bold ctermfg=215 cterm=bold
highlight Special guifg=aquamarine2 gui=NONE ctermfg=122 cterm=NONE
highlight Underlined guifg=#80a0ff gui=underline
highlight Ignore guifg=gray40 gui=NONE ctermfg=241 cterm=NONE
highlight Error guifg=white guibg=red
highlight Todo guifg=black guibg=#fcd38a gui=none
"highlight Todo guifg=orangered guibg=yellow2 gui=NONE ctermfg=202 ctermbg=226 cterm=NONE

hi CursorLine                        guibg=gray20

if exists("g:desertEx_statusLineColor")
  highlight User1 guifg=gray10 gui=bold guibg=#eeb422
  highlight User2 guifg=gray85 gui=bold guibg=gray30
  highlight User3 guifg=gray10 gui=bold guibg=gray50
  highlight User4 guifg=gray10 gui=bold guibg=gray70
  highlight User5 guifg=gray10 gui=bold guibg=gray90
endif

