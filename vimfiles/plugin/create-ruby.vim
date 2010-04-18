" Vim plugin that generates new Ruby source file when you type
"    vim nonexistent.rb.
"
" Author     :   Ivan Porto Carrero <ivan@cloudslide.net>


function! MakeRubyFile()
    if exists("b:template_used") && b:template_used
        return
    endif
    
    let b:template_used = 1
    call append("0", "# coding: utf-8")
    call append(".", "")
    
endfunction

au BufNewFile *.rb call MakeRubyFile()

" vim: set ts=2 sw=2 et: