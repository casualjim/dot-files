
if exists("loaded_codefellow")
    finish
endif
let loaded_codefellow=1

if !has('python')
    throw "CodeFellow requires Python support!"
endif

if !exists('g:codefellow_verbose')
  let g:codefellow_verbose = 0
endif

if !exists('g:codefellow_no_default_mappings')
  " default completion: (<c-s> will not work in console Vim !):
  autocmd FileType scala inoremap <buffer> <C-x><C-o> <C-O>:set omnifunc=codefellow#CompleteMember<CR><c-x><c-o>

  autocmd FileType scala inoremap <buffer> <C-s><C-m> <C-O>:set omnifunc=codefellow#CompleteMember<CR><c-x><c-o>
  autocmd FileType scala inoremap <buffer> <C-s><C-s> <C-O>:set omnifunc=codefellow#CompleteScope<CR><c-x><c-o>
  "autocmd FileType scala inoremap <buffer> <C-s><C-n> <C-O>:set omnifunc=codefellow#CompleteSmart<CR><c-x><c-o>
  
  autocmd FileType scala noremap <buffer> <C-s><C-t> <esc>:<c-u>call codefellow#PrintTypeInfo()<CR>
  autocmd FileType scala noremap <buffer> <F1> :call codefellow#PrintTypeInfo()<CR>

  " If current file is a SBT project always map F9
  let ft_only  = isdirectory('project/build') 
        \ ? ["",""]
        \ : ['autocmd FileType scala','<buffer>']
  exec ft_only[0]' noremap '.ft_only[1].' <F9> :call codefellow#CompileFile()<CR>'
endif

command CodefellowCompileAll call codefellow#CompileFile()
command CodefellowDebug call codefellow#EnableDebugging()

" Balloon type information
if has("balloon_eval")
    autocmd FileType scala setlocal ballooneval
    autocmd FileType scala setlocal balloondelay=300
    autocmd FileType scala setlocal balloonexpr=codefellow#BalloonType()
endif

" Hooks to sync Vim with CodeFellow daemon
" autocmd BufReadPost *.scala call codefellow#ReloadFile()
autocmd BufWritePost *.scala call codefellow#ReloadFile()

command! -nargs=1 ListPackagesContainingClass for i in codefellow_add_import#Find_package_of_class(<f-args>) | echo substitute(i,'|','        ','') | endfor
