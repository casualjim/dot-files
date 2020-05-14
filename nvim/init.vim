let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0
"----------------------------------------------
" Plugin management
"
" Download vim-plug from the URL below and follow the installation
" instructions:
" https://github.com/junegunn/vim-plug
"----------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Dependencies
Plug 'Shougo/neocomplcache'        " Depenency for Shougo/neosnippet
Plug 'godlygeek/tabular'           " This must come before plasticboy/vim-markdown
Plug 'tpope/vim-rhubarb'           " Dependency for tpope/fugitive

" General plugins
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'  " Default snippets for many languages
Plug 'itchyny/lightline.vim'       " A pretty statusline, bufferline integration
Plug 'bling/vim-bufferline'
Plug 'ctrlpvim/ctrlp.vim'          " CtrlP is installed to support tag finding in vim-go
Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/calendar.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar' " Functions, class data etc. REQUIREMENTS: (exuberant)-ctags
Plug 'mhinz/vim-signify'
Plug 'neomake/neomake'
Plug 'rbgrouleff/bclose.vim'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'sebdah/vim-delve'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'Raimondi/delimitMate'
Plug 'vimwiki/vimwiki'

" Language support
Plug 'aklt/plantuml-syntax'                    " PlantUML syntax highlighting
Plug 'cespare/vim-toml'                        " toml syntax highlighting
Plug 'chr4/nginx.vim'                          " nginx syntax highlighting
Plug 'chrisbra/vim-zsh'                        " zsh syntax highlighting
Plug 'fatih/vim-go'                            " Go support
Plug 'fishbullet/deoplete-ruby'                " Ruby auto completion
Plug 'hashivim/vim-terraform'                  " Terraform syntax highlighting
Plug 'leafgarland/typescript-vim'              " TypeScript syntax highlighting
Plug 'lifepillar/pgsql.vim'                    " PostgreSQL syntax highlighting
Plug 'mxw/vim-jsx'                             " JSX syntax highlighting
Plug 'mdempsky/gocode', { 'rtp': 'nvim', 'do': '~/.local/share/nvim/plugged/gocode/nvim/symlink.sh' } " Go auto completion
Plug 'pangloss/vim-javascript'                 " JavaScript syntax highlighting
Plug 'plasticboy/vim-markdown'                 " Markdown syntax highlighting
Plug 'rust-lang/rust.vim'

" Autocomplete support
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}      " Go auto completion
Plug 'zchee/deoplete-jedi'                     " Python auto completion
Plug 'zchee/deoplete-zsh'
Plug 'zchee/deoplete-clang'
Plug 'zchee/deoplete-asm'
Plug 'zchee/deoplete-docker'
"Plug 'zchee/deoplete-make'
"Plug 'carlitux/deoplete-ternjs'

" Glorious colorschemes
Plug 'nanotech/jellybeans.vim'
Plug 'jnurmine/Zenburn'

" Work with colors
Plug 'guns/xterm-color-table.vim'
Plug 'lilydjwg/colorizer'

call plug#end()

""" User interface {{{
""" Syntax highlighting {{{
filetype plugin indent on                   " detect file plugin+indent
syntax on                                   " syntax highlighting

set t_Co=256                                " 256-colors
set termguicolors
set background=dark                         " we're using a dark bg
" colors jellybeans                           " select colorscheme
colors desertEx                             " select colorscheme

au BufNewFile,BufRead *.txt set ft=sh tw=119  " opens .txt w/highlight
au BufNewFile,BufRead *.tex set ft=tex tw=119 " we don't want plaintex
augroup markdown
  au!
  au BufNewFile,BufRead *.md,*.markdown setlocal ft=ghmarkdown tw=119 " markdown, not modula
augroup END

""" Custom highlighting, where NONE uses terminal background {{{
function! CustomHighlighting()
  highlight Normal ctermbg=NONE
  highlight nonText ctermbg=NONE
  highlight LineNr ctermbg=NONE
  highlight SignColumn ctermbg=NONE
  highlight CursorLine ctermbg=235
endfunction

call CustomHighlighting()
""" }}}
""" }}}
""" Interface general {{{
set cursorline                              " hilight cursor line
set more                                    " ---more--- like less
set number                                  " line numbers
set scrolloff=3                             " lines above/below cursor
set showcmd                                 " show cmds being typed
set title                                   " window title
set vb t_vb=                                " disable beep and flashing
set wildignore+=.hg,.git,.svn " Version Controls"
set wildignore+=*.aux,*.out,*.toc "Latex Indermediate files"
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg "Binary Imgs"
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.a,*.so,*.dylib "Compiled Object files"
set wildignore+=*.spl "Compiled speolling world list"
set wildignore+=*.swp,*.swo "Vim swap files"
set wildignore+=*.DS_Store "OSX SHIT"
set wildignore+=*.luac "Lua byte code"
set wildignore+=migrations "Django migrations"
set wildignore+=*.pyc "Python Object codes"
set wildignore+=*.orig "Merge resolution files"
set wildignore+=*.pdf,*.mkv "No video files
set wildignore+=*.class "java/scala class files"
set wildignore+=*.bak " Backup files
set wildmenu                                " better auto complete
set wildmode=longest,list                   " bash-like auto complete
""" Encoding {{{
" If you're having problems with some characters you can force
" UTF-8 if your locale is something else.
" WARNING: this will affect encoding used when editing files!
"
set encoding=utf-8                    " for character glyphs
""" }}}
""" Gvim {{{
set guifont=FuraCode\ Nerd\ Font\ Mono:h11
if has("unix")
  set guioptions-=a
endif
if has("gui_mac") || has("gui_macvim")
  set guifont=Fira\ Code\ Retina:h13
endif
if has("gui_win32") || has("gui_win32s")
  set guifont=Consolas:h10
  set enc=utf-8
endif

set guioptions-=m                       " remove menubar
set guioptions-=T                       " remove toolbar
set guioptions-=r                       " remove right scrollbar
set lsp=2
""" }}}
""" }}}
""" }}}
""" General settings {{{
set hidden                                      " buffer change, more undo
set history=1000                                " default 20
set iskeyword+=_,$,@,%,#                        " not word dividers
set laststatus=2                                " always show statusline
set linebreak                                   " don't cut words on wrap
set listchars=tab:>\                            " > to highlight <tab>
set list                                        " displaying listchars
set mouse=a                                     " disable mouse
set nolist                                      " wraps to whole words
set noshowmode                                  " hide mode cmd line
set noexrc                                      " don't use other .*rc(s)
set nostartofline                               " keep cursor column pos
set nowrap                                      " don't wrap lines
set numberwidth=5                               " 99999 lines
set shortmess+=I                                " disable startup message
set splitbelow                                  " splits go below w/focus
set splitright                                  " vsplits go right w/focus
set ttyfast                                     " for faster redraws etc
"    set clipboard=unnamedplus                       " enable clipboard, http://stackoverflow.com/a/14312911
""" Folding {{{
set foldcolumn=0                            " hide folding column
set foldmethod=indent                       " folds using indent
set foldnestmax=10                          " max 10 nested folds
set foldlevelstart=99                       " folds open by default
""" }}}
""" Search and replace {{{
set gdefault                                " default s//g (global)
set incsearch                               " "live"-search
""" }}}
""" Matching {{{
set matchtime=2                             " time to blink match {}
set matchpairs+=<:>                         " for ci< or ci>
set showmatch                               " tmpjump to match-bracket
""" }}}
""" Return to last edit position when opening files {{{
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \     exe "normal! g`\"" |
      \ endif
""" }}}
""" }}}
""" Files {{{
" set autochdir                                   " always use curr. dir.
set autoread                                    " refresh if changed
set confirm                                     " confirm changed files
set noautowrite                                 " never autowrite
set nobackup                                    " disable backups
set updatecount=50                              " update swp after 50chars
""" Persistent undo. Requires Vim 7.3 {{{
if has('persistent_undo') && exists("&undodir")
  set undodir=$HOME/.vim/undo/            " where to store undofiles
  set undofile                            " enable undofile
  set undolevels=500                      " max undos stored
  set undoreload=10000                    " buffer stored undos
endif
""" }}}
""" }}}
""" Text formatting {{{
set autoindent                                  " preserve indentation
set backspace=indent,eol,start                  " smart backspace
set cinkeys-=0#                                 " don't force # indentation
set expandtab                                   " no real tabs
set ignorecase                                  " by default ignore case
set nrformats+=alpha                            " incr/decr letters C-a/-x
set shiftround                                  " be clever with tabs
set shiftwidth=2                                " default 8
set smartcase                                   " sensitive with uppercase
set smarttab                                    " tab to 0,4,8 etc.
set softtabstop=2                               " "tab" feels like <tab>
set tabstop=2                                   " replace <TAB> w/4 spaces
""" Only auto-comment newline for block comments {{{
au FileType c,cpp setlocal comments -=:// comments +=f://

" http://stackoverflow.com/questions/16743112/open-item-from-quickfix-window-in-vertical-split
autocmd! FileType qf nnoremap <buffer> <leader><Enter> <C-w><Enter><C-w>L
"don't clutter my directories with swap files
"set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
"set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

""" }}}
""" }}}
""" Keybindings {{{
""" General {{{
" Remap <leader>
let mapleader=","

" Quickly edit/source .vimrc
noremap <leader>ve :edit $HOME/.config/nvim/init.vim<CR>
noremap <leader>vs :source $HOME/.config/nvim/init.vim<CR>

" Yank(copy) to system clipboard
"noremap <leader>y "+y
"
" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
vnoremap <S-Del> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

" CTRL-V and SHIFT-Insert are Paste
map <C-V>		"+gP
map <S-Insert>		"+gP

cmap <C-V>		<C-R>+
cmap <S-Insert>		<C-R>+

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

" Bubbling (bracket matching)
nmap <C-up> [e
nmap <C-down> ]e
vmap <C-up> [egv
vmap <C-down> ]egv

" We don't need any help!
inoremap <F1> <nop>
nnoremap <F1> <nop>
vnoremap <F1> <nop>

" Disable annoying ex mode (Q)
map Q <nop>

nmap <silent> <F2> :NERDTreeToggle<CR>
nnoremap <silent> <C-L> :noh<CR><C-L>

" Toggle tagbar (definitions, functions etc.)
map <F1> :TagbarToggle<CR>
nnoremap <F5> :GundoToggle<CR>

" Toggle pastemode, doesn't indent
set pastetoggle=<F3>

" Syntastic - toggle error list. Probably should be toggleable.
noremap <silent><leader>lo :Errors<CR>
noremap <silent><leader>lc :lcl<CR>


function! MyMode()
    let fname = expand('%:t')
    return fname == '__Tagbar__' ? 'Tagbar' :
            \ fname == 'ControlP' ? 'CtrlP' :
            \ fname == '__Gundo__' ? 'Gundo' :
            \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
            \ fname == 'NERD_Tree' ? 'NERDTree' :
            \ winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyFugitive()
    try
        if expand('%:t') !~? 'Tagbar' && exists('*fugitive#head')
            let mark = '± '
            let _ = fugitive#head()
            return strlen(_) ? mark._ : ''
        endif
    catch
    endtry
    return ''
endfunction

function! MyReadonly()
    return &ft !~? 'help' && &readonly ? '≠' : '' " or ⭤
endfunction

"function! CtrlPMark()
    "if expand('%:t') =~ 'ControlP'
        "call lightline#link('iR'[g:lightline.ctrlp_regex])
        "return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
            "\ , g:lightline.ctrlp_next], 0)
    "else
        "return ''
    "endif
"endfunction

function! MyBufferline()
    call bufferline#refresh_status()
    let b = g:bufferline_status_info.before
    let c = g:bufferline_status_info.current
    let a = g:bufferline_status_info.after
    let alen = strlen(a)
    let blen = strlen(b)
let clen = strlen(c)
    let w = winwidth(0) * 4 / 11
    if w < alen+blen+clen
        let whalf = (w - strlen(c)) / 2
        let aa = alen > whalf && blen > whalf ? a[:whalf] : alen + blen < w - clen || alen < whalf ? a : a[:(w - clen - blen)]
        let bb = alen > whalf && blen > whalf ? b[-(whalf):] : alen + blen < w - clen || blen < whalf ? b : b[-(w - clen - alen):]
        return (strlen(bb) < strlen(b) ? '...' : '') . bb . c . aa . (strlen(aa) < strlen(a) ? '...' : '')
    else
        return b . c . a
    endif
endfunction

function! MyFileformat()
    return winwidth('.') > 90 ? &fileformat : ''
endfunction

function! MyFileencoding()
    return winwidth('.') > 80 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyFiletype()
    return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

let g:ctrlp_status_func = {
    \ 'main': 'CtrlPStatusFunc_1',
    \ 'prog': 'CtrlPStatusFunc_2',
    \ }

"function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
    "let g:lightline.ctrlp_regex = a:regex
    "let g:lightline.ctrlp_prev = a:prev
    "let g:lightline.ctrlp_item = a:item
    "let g:lightline.ctrlp_next = a:next
    "return lightline#statusline(0)
"endfunction

"function! CtrlPStatusFunc_2(str)
    "return lightline#statusline(0)
"endfunction

"let g:tagbar_status_func = 'TagbarStatusFunc'

"function! TagbarStatusFunc(current, sort, fname, ...) abort
    "let g:lightline.fname = a:fname
    "return lightline#statusline(0)
"endfunction

" CtrlP - don't recalculate files on start (slow)
let g:ctrlp_clear_cache_on_exit = 1
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = {
    \ 'types': {
        \ 1: ['.git', 'cd %s && git ls-files'],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
    \ 'fallback': 'find %s -type f'
    \ }
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': '\v\.(exe|so|dll|class|a)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }
let g:ctrlp_root_markers = ['.ctrlp']

" TagBar
let g:tagbar_left = 0
let g:tagbar_width = 30
set tags=./tags;/

" Scala {{{3
let g:tagbar_type_scala = {
    \ 'ctagstype': 'scala',
    \ 'kinds': [
        \ 'p:packages:1',
        \ 'V:values',
        \ 'v:variables',
        \ 'T:types',
        \ 't:traits',
        \ 'o:objects',
        \ 'a:aclasses',
        \ 'c:classes',
        \ 'r:cclasses',
        \ 'm:methods'
    \ ],
    \ 'sro': '.',
    \ 'kind2scope': {
        \ 't' : 'trait',
        \ 'o' : 'object',
        \ 'C' : 'case class',
        \ 'O' : 'case object',
        \ 'c' : 'class'
    \ },
    \ 'scope2kind': {
        \ 'trait'          : 't',
        \ 'object'         : 'o',
        \ 'case class'     : 'C',
        \ 'case object'    : 'O',
        \ 'class'          : 'c'
    \ }
\ }

" define the go language tags
" assumes you have
" make use of the gotags tool: https://github.com/jstemmer/gotags
" cd $GOPATH
" go get -u github.com/jstemmer/gotags
"
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }


let g:NERDTreeShowHidden = 1
let g:NERDTreeShortHiddenFirst = 1
let g:NERDTreeShortIgnore = ['\.sw(o|p)$']
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

let g:deoplete#enable_at_startup = 1

let g:go_bin_path = expand("$GOPATH/bin")
let g:go_disable_autoinstall = 0
let g:go_fmt_command = "goimports"
let g:go_fmt_experimental = 1
let g:go_auto_type_info = 1
let g:go_info_mode = 'guru'
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_arguments = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_fields = 1
let g:go_highlight_structs = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_list_type = "quickfix"
let g:go_oracle_include_tests = 1
let g:go_oracle_scope = 'github.com/go-swagger/go-swagger/cmd/swagger'


let g:gitgutter_enabled = 0
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 1
let g:gitgutter_signs = 1
let g:gitgutter_highlight_lines = 0

" js beautify
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
autocmd FileType javascript vnoremap <buffer>  <c-f> :call RangeJsBeautify()<cr>
autocmd FileType html vnoremap <buffer> <c-f> :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <c-f> :call RangeCSSBeautify()<cr>

" xml-like
iabbrev </ </<C-X><C-O>
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

" go things
au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <Leader>e <Plug>(go-rename)
au FileType go nmap <Leader>oc <Plug>(go-callers)
au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go map <leader>ra :wa<CR> :GolangTestCurrentPackage<CR>
au FileType go map <leader>rf :wa<CR> :GolangTestFocussed<CR>

" go template support
au BufRead,BufNewFile *.gotmpl set filetype=gotexttmpl
au BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl

let googurl_api_key = 'AIzaSyARvfSoMQYyohsgk3kkVwHAKHFDoMQV-ec'

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'javascript.jsx': ['javascript-typescript-stdio'],
    \ 'typescript': ['javascript-typescript-stdio'],
    \ 'typescript.tsx': ['javascript-typescript-stdio'],
    \ }

augroup filetype_rust
    autocmd!
    autocmd BufReadPost *.rs setlocal filetype=rust
augroup END
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>

inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" : deoplete#manual_complete()

"au VimLeave * silent execute '!echo -ne "\e[ q"'
au VimLeave * set guicursor=a:ver25-blinkon250
