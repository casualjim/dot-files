"-----------------------------------------------"
" Author:       Tim Sæterøy                     "
" Homepage:     http://thevoid.no               "
" Source:       http://github.com/timss/vimconf "
"-----------------------------------------------"

" vimconf is not vi-compatible
set nocompatible


""" Automatically make needed files and folders on first run
""" If you don't run *nix you're on your own (as in remove this) {{{
call system("mkdir -p $HOME/.vim/{plugin,undo}")
if !filereadable($HOME . "/.vimrc.bundles") | call system("touch $HOME/.vimrc.bundles") | endif
if !filereadable($HOME . "/.vimrc.first") | call system("touch $HOME/.vimrc.first") | endif
if !filereadable($HOME . "/.vimrc.last") | call system("touch $HOME/.vimrc.last") | endif
""" }}}
""" Vundle plugin manager {{{
""" Automatically setting up Vundle, taken from
""" http://www.erikzaadi.com/2012/03/19/auto-installing-vundle-from-your-vimrc/ {{{
let has_vundle=1
let g:python_host_prog = '/usr/local/bin/python'
if !filereadable($HOME."/.vim/bundle/vundle/README.md")
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p $HOME/.vim/bundle
  silent !git clone https://github.com/gmarik/vundle $HOME/.vim/bundle/vundle
  let has_vundle=0
endif
""" }}}
""" Initialize Vundle {{{
filetype off                                " required to init
set rtp+=$HOME/.vim/bundle/vundle/          " include vundle
call vundle#rc()                            " init vundle
""" }}}
""" Github repos, uncomment to disable a plugin {{{
" Recursive vundle, omg!
Plugin 'gmarik/vundle'

""" Local bundles (and only bundles in this file!) {{{{
if filereadable($HOME."/.vimrc.bundles")
  source $HOME/.vimrc.bundles
endif
""" }}}

" Edit files using sudo/su
Plugin 'chrisbra/SudoEdit.vim'

" Fuzzy finder (files, mru, etc)
Plugin 'kien/ctrlp.vim'

" A pretty statusline, bufferline integration
Plugin 'itchyny/lightline.vim'
Plugin 'bling/vim-bufferline'

" Close all other buffers but this one
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/vimshell.vim'

" highlight trailing whitespace red
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'terryma/vim-multiple-cursors'

" easymotion
Plugin 'Lokaltog/vim-easymotion'

" tmux integration
Plugin 'tmux-plugins/vim-tmux'
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'christoomey/vim-tmux-navigator'

" Glorious colorschemes
Plugin 'nanotech/jellybeans.vim'
Plugin 'jnurmine/Zenburn'
"Plugin 'jaromero/vim-monokai-refined'

" editorconfig integration
Plugin 'editorconfig/editorconfig-vim'

" Work with colors
Plugin 'guns/xterm-color-table.vim'
"Plugin 'lilydjwg/colorizer'

" Super easy commenting, toggle comments etc
Plugin 'scrooloose/nerdcommenter'

" Autoclose (, " etc
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'Raimondi/delimitMate'
"Plugin 'Townk/vim-autoclose'

" Git wrapper inside Vim
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
"Plugin 'jaxbot/github-issues.vim'

" Align your = etc.
Plugin 'vim-scripts/Align'

" Snippets like textmate
"Plugin 'Shougo/neocomplete'
"Plugin 'Shougo/neosnippet'
"Plugin 'Shougo/neosnippet-snippets'
Plugin 'sjl/gundo.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
"Plugin 'bufexplorer.zip'

" Awesome syntax checker.
" REQUIREMENTS: See :h syntastic-intro
Plugin 'scrooloose/syntastic'

" Functions, class data etc.
" REQUIREMENTS: (exuberant)-ctags
Plugin 'majutsushi/tagbar'
Plugin 'mtth/scratch.vim'

" Scala support
Plugin 'derekwyatt/vim-scala'
Plugin 'derekwyatt/vim-sbt'
"Plugin 'ktvoelker/sbt-vim'
Plugin 'tpope/vim-classpath'
Plugin 'GEverding/vim-hocon'

" Ansible support
Plugin 'chase/vim-ansible-yaml'

" Docker support
Plugin 'ekalinin/Dockerfile.vim'

" SystemD support
Plugin 'Matt-Deacalion/vim-systemd-syntax'

" Vagrant support
Plugin 'markcornick/vim-vagrant'
Plugin 'b4b4r07/vim-hcl'
Plugin 'fatih/vim-hclfmt'

" NGinX support
"Plugin 'evanmiller/nginx-vim-syntax'

" Varnish cache support
" Plugin 'casualjim/vim-varnish'

" TOML support
Plugin 'cespare/vim-toml'

" Go support
Plugin 'fatih/vim-go'
"Plugin 'cespare/vim-go-templates'
"Plugin 'benmills/vimux-golang'

" shorten urls
"Plugin 'sethbaur/googurl.vim'

" Rust support
Plugin 'wting/rust.vim'
Plugin 'ebfe/vim-racer'

" html5 support
Plugin 'othree/html5.vim'

" less, css etc support
Plugin 'vim-less'
Plugin 'hail2u/vim-css3-syntax'

" JavaScript
Plugin 'mklabs/grunt.vim'
Plugin 'moll/vim-node'
Plugin 'pangloss/vim-javascript'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'matthewsimo/angular-vim-snippets'
Plugin 'burnettk/vim-angular'

" React.js
Plugin 'mxw/vim-jsx'

"Plugin 'marijnh/tern_for_vim'
Plugin 'myhere/vim-nodejs-complete'
Plugin 'elzr/vim-json'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'einars/js-beautify'

" fedora files
Plugin 'tangledhelix/vim-kickstart'

" ascii diagrams
Plugin 'vim-scripts/DrawIt'
" markdown support
Plugin 'tpope/vim-markdown'
Plugin 'jtratner/vim-flavored-markdown'
Plugin 'shime/vim-livedown'

""" }}}
""" Installing plugins the first time {{{
if has_vundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :BundleInstall
endif
""" }}}
""" }}}
""" Local leading config, only use for prerequisites as it will be
""" overwritten by anything below {{{{
if filereadable($HOME."/.vimrc.first")
  source $HOME/.vimrc.first
endif
""" }}}
""" User interface {{{
""" Syntax highlighting {{{
filetype plugin indent on                   " detect file plugin+indent
syntax on                                   " syntax highlighting

set t_Co=256                                " 256-colors
set termguicolors
set background=dark                         " we're using a dark bg
colors jellybeans                           " select colorscheme
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
if has("unix")
  set guifont=Consolas\ 11
  "set guifont=Fira\ Code\ 10
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
noremap <leader>ve :edit $HOME/.vimrc<CR>
noremap <leader>vs :source $HOME/.vimrc<CR>

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

" Pasting blockwise and linewise selections is not possible in Insert and
        " Visual mode without the +virtualedit feature.  They are pasted as if they
        " were characterwise instead.
        " Uses the paste.vim autoload script.
        " Use CTRL-G u to have CTRL-Z only undo the paste.

        exe 'inoremap <script> <C-V> <C-G>u' . paste#paste_cmd['i']
        exe 'vnoremap <script> <C-V> ' . paste#paste_cmd['v']

        imap <S-Insert>		<C-V>
        vmap <S-Insert>		<C-V>

        " Use CTRL-Q to do what CTRL-V used to do
        noremap <C-Q>		<C-V>

        " Use CTRL-S for saving, also in Insert mode
        noremap <C-S>		:update<CR>
        vnoremap <C-S>		<C-C>:update<CR>
        inoremap <C-S>		<C-O>:update<CR>

        " Toggle text wrapping
        nmap <silent> <leader>w :set invwrap<CR>:set wrap?<CR>

        " Toggle folding
        nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
        vnoremap <Space> zf

        " Bubbling (bracket matching)
        nmap <C-up> [e
        nmap <C-down> ]e
        vmap <C-up> [egv
        vmap <C-down> ]egv

        " Treat wrapped lines as normal lines
        nnoremap j gj
        nnoremap k gk

        " Working ci(, works for both breaklined, inline and multiple ()
        nnoremap ci( %ci(

        " We don't need any help!
        inoremap <F1> <nop>
        nnoremap <F1> <nop>
        vnoremap <F1> <nop>

        " Disable annoying ex mode (Q)
        map Q <nop>

        nmap <silent> <F2> :NERDTreeToggle<CR>
        nnoremap <silent> <C-L> :noh<CR><C-L>
    """ }}}
    """ Functions or fancy binds {{{{
        """ Toggle syntax highlighting {{{
            function! ToggleSyntaxHighlighthing()
                if exists("g:syntax_on")
                    syntax off
                else
                    syntax on
                    call CustomHighlighting()
                endif
            endfunction

            nnoremap <leader>s :call ToggleSyntaxHighlighthing()<CR>
        """ }}}
        """ Highlight characters past 119, toggle with <leader>h
        """ You might want to override this function and its variables with
        """ your own in .vimrc.last which might set for example colorcolumn or
        """ even the textwidth. See https://github.com/timss/vimconf/pull/4 {{{
            let g:overlength_enabled = 0
            highlight OverLength ctermbg=238 guibg=#444444

            function! ToggleOverLength()
                if g:overlength_enabled == 0
                    match OverLength /\%119v.*/
                    let g:overlength_enabled = 1
                    echo 'OverLength highlighting turned on'
                else
                    match
                    let g:overlength_enabled = 0
                    echo 'OverLength highlighting turned off'
                endif
            endfunction

            nnoremap <leader>h :call ToggleOverLength()<CR>
        """ }}}
        """ Toggle relativenumber using <leader>r {{{
            nnoremap <leader>r :call NumberToggle()<CR>

            function! NumberToggle()
                if(&relativenumber == 1)
                    set number
                else
                    set relativenumber
                endif
            endfunction
        """ }}}
        """ Remove multiple empty lines {{{
            function! DeleteMultipleEmptyLines()
                g/^\_$\n\_^$/d
            endfunction

            nnoremap <leader>ld :call DeleteMultipleEmptyLines()<CR>
        """ }}}
        """ Split to relative header/source {{{
            function! SplitRelSrc()
                let s:fname = expand("%:t:r")

                if expand("%:e") == "h"
                    set nosplitright
                    exe "vsplit" fnameescape(s:fname . ".cpp")
                    set splitright
                elseif expand("%:e") == "cpp"
                    exe "vsplit" fnameescape(s:fname . ".h")
                endif
            endfunction

            nnoremap <leader>le :call SplitRelSrc()<CR>
        """ }}}
        """ Strip trailing whitespace, return to cursors at save {{{
            function! <SID>StripTrailingWhitespace()
                let l = line(".")
                let c = col(".")
                %s/\s\+$//e
                call cursor(l, c)
            endfunction

            autocmd FileType c,cpp,css,html,perl,python,sh autocmd
                        \ BufWritePre <buffer> :call <SID>StripTrailingWhitespace()
        """ }}}
    """ }}}
    """ Plugins {{{
        " Toggle tagbar (definitions, functions etc.)
        map <F1> :TagbarToggle<CR>
        nnoremap <F5> :GundoToggle<CR>

        " Toggle pastemode, doesn't indent
        set pastetoggle=<F3>

        " Syntastic - toggle error list. Probably should be toggleable.
        noremap <silent><leader>lo :Errors<CR>
        noremap <silent><leader>lc :lcl<CR>
    """ }}}
""" }}}
""" Plugin settings {{{
    """ Lightline {{{
        let g:lightline = {
            \ 'colorscheme': 'Tomorrow_Night',
            \ 'active': {
            \     'left': [
            \         ['mode', 'paste'],
            \         ['fugitive', 'readonly'],
            \         ['ctrlpmark', 'bufferline']
            \     ],
            \     'right': [
            \         ['lineinfo'],
            \         ['percent'],
            \         ['fileformat', 'fileencoding', 'filetype', 'syntastic']
            \     ]
            \ },
            \ 'component': {
            \     'paste': '%{&paste?"!":""}'
            \ },
            \ 'component_function': {
            \     'mode'         : 'MyMode',
            \     'fugitive'     : 'MyFugitive',
            \     'readonly'     : 'MyReadonly',
            \     'ctrlpmark'    : 'CtrlPMark',
            \     'bufferline'   : 'MyBufferline',
            \     'fileformat'   : 'MyFileformat',
            \     'fileencoding' : 'MyFileencoding',
            \     'filetype'     : 'MyFiletype'
            \ },
            \ 'component_expand': {
            \     'syntastic': 'SyntasticStatuslineFlag',
            \ },
            \ 'component_type': {
            \     'syntastic': 'middle',
            \ },
            \ 'subseparator': {
            \     'left': '|', 'right': '|'
            \ }
            \ }

        "let g:lightline.mode_map = {
            "\ 'n'      : ' N ',
            "\ 'i'      : ' I ',
            "\ 'R'      : ' R ',
            "\ 'v'      : ' V ',
            "\ 'V'      : 'V-L',
            "\ 'c'      : ' C ',
            "\ "\<C-v>" : 'V-B',
            "\ 's'      : ' S ',
            "\ 'S'      : 'S-L',
            "\ "\<C-s>" : 'S-B',
            "\ '?'      : '      ' }

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

        function! CtrlPMark()
            if expand('%:t') =~ 'ControlP'
                call lightline#link('iR'[g:lightline.ctrlp_regex])
                return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
                    \ , g:lightline.ctrlp_next], 0)
            else
                return ''
            endif
        endfunction

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

        function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
            let g:lightline.ctrlp_regex = a:regex
            let g:lightline.ctrlp_prev = a:prev
            let g:lightline.ctrlp_item = a:item
            let g:lightline.ctrlp_next = a:next
            return lightline#statusline(0)
        endfunction

        function! CtrlPStatusFunc_2(str)
            return lightline#statusline(0)
        endfunction

        let g:tagbar_status_func = 'TagbarStatusFunc'

        function! TagbarStatusFunc(current, sort, fname, ...) abort
            let g:lightline.fname = a:fname
            return lightline#statusline(0)
        endfunction

        augroup AutoSyntastic
            autocmd!
            autocmd BufWritePost *.c, *.js,*.cpp,*.perl,*py,*.scala,*.go,*.json,*.rb call s:syntastic()
        augroup END
        function! s:syntastic()
            SyntasticCheck
            call lightline#update()
        endfunction
    """ }}}

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

    " Syntastic - This is largely up to your own usage, and override these
    "             changes if be needed. This is merely an exemplification.
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:syntastic_enable_signs = 1
    let g:syntastic_error_symbol = "✗"
    let g:syntastic_warning_symbol = "⚠"
    let g:syntastic_aggregate_errors = 1
    let g:syntastic_sort_aggregate_errors = 1
    let g:syntastic_extra_filetypes = [ "make", "gitcommit" ]
    let g:syntastic_cpp_check_header = 1
    let g:syntastic_cpp_compiler_options = ' -std=c++0x'
    let g:syntastic_go_checkers = ['gofmt', 'govet', 'gotype', 'golint', 'errcheck']
    let g:syntastic_go_govet_args = '-printf=false -structtags=false'
    let g:syntastic_go_gometalinter_args = '--vendor --fast'
    let g:syntastic_json_checkers = ['jsonlint']
    let g:syntastic_javascript_checkers = ['eslint']
    let g:syntastic_mode_map = {
        \ 'mode': 'active',
        \ 'active_filetypes':
            \ ['c', 'cpp', 'python', 'scala', 'js', 'json', 'yaml', 'zsh', 'ruby'],
        \ 'passive_filetypes':
            \ ['perl', 'go']}

    let g:NERDTreeShowHidden = 1
    let g:NERDTreeShortHiddenFirst = 1
    let g:NERDTreeShortIgnore = ['\.sw(o|p)$']
    let g:jsx_ext_required = 0 " Allow JSX in normal JS files

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
    let g:go_oracle_scope = 'github.com/go-swagger/go-swagger/cmd/swagger github.com/vmware/cello/cmd/cello'

    function! g:UltiSnips_Complete()
      call UltiSnips_ExpandSnippet()
      if g:ulti_expand_res == 0
          if pumvisible()
              return "\<C-n>"
          else
              call UltiSnips_JumpForwards()
              if g:ulti_jump_forwards_res == 0
                return "\<TAB>"
              endif
          endif
      endif
      return ""
    endfunction

    au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsListSnippets="<c-e>"

    function! g:UltiSnips_Complete()
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
            if pumvisible()
                return "\<C-n>"
            else
                call UltiSnips#JumpForwards()
                if g:ulti_jump_forwards_res == 0
                   return "\<TAB>"
               endif
            endif
        endif
        return ""
     endfunction

    au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
    let g:UltiSnipsExpandTrigger="<s-tab>"
    let g:UltiSnipsListSnippets="<c-e>"

    let g:vim_json_syntax_conceal = 0
    let g:angular_find_ignore = ['build/', 'dist/']

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

""" }}}
""" Local ending config, will overwrite anything above. Generally use this. {{{{
    if filereadable($HOME."/.vimrc.last")
        source $HOME/.vimrc.last
    endif
""" }}}
