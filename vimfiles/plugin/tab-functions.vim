nmap <C-Tab> :call TabParams()<CR>
function! TabParams()
    echo "tabstop:     ".&tabstop
    echo "shiftwidth:  ".&shiftwidth
    echo "softtabstop: ".&softtabstop
    echo "expandtab:   ".&expandtab
endfunc

