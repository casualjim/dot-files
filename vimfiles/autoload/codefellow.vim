"
" Sends a message to the CodeFellow server a return the response
"
function s:SendMessage(type, ...)
python << endpython
import socket
import vim
try:
    s = socket.socket()
    s.connect(("localhost", 9081))

    argsSize = int(vim.eval("a:0"))
    args = []
    for i in range(1, argsSize + 1):
        args.append(vim.eval("a:" + str(i)))

    # if there is a case where you need proper quoting consider using 
    # http://github.com/MarcWeber/scion-backend-vim/blob/devel-vim/autoload/json.vim
    msg = "{"
    msg += '"moduleIdentifierFile": "' + vim.eval('expand("%:p")') + '",'
    msg += '"message": "' + vim.eval("a:type") + '",'
    msg += '"arguments": [' + ",".join(map(lambda e: '"' + e + '"', args)) + ']'
    msg += "}"
    msg += "\nENDREQUEST\n"
    s.sendall(msg)

    # read until server closes connection
    data = ""
    while 1:
        tmp = s.recv(1024)
        if not tmp:
            break
        data += tmp

    vim.command('return ' + data)
except:
    # Probably not connected
    # Stay silent to not interrupt
    vim.command('return ""')
endpython
endfunction


execute "sign define codefellow_marker_error text=! linehl=ErrorMsg"

function s:ShowCompilerMarkers()
    sign unplace *
    for a in getqflist()
        let id = a.bufnr . a.lnum
        execute ":sign place " . id . " line=" . a.lnum . " name=codefellow_marker_error buffer=" . a.bufnr
    endfor
endfunction

"
" Returns the absolute path of the current file
"
function s:getFileName()
    return expand("%:p")
endfunction

"
" Returns the index in the current line where the word under the cursor starts
"
function s:getWordUnderCursorIndex()
    let line = getline('.')
    let i = col('.')
    while i > 0
        let value = line[i - 1]
        if value == '.' || value == ' '
            return i
        endif
        let i -= 1
    endwhile
    return i
endfunction

function codefellow#CompleteMember(findstart, base)
    if a:findstart
        return <SID>getWordUnderCursorIndex()
    else
        silent w!
        call codefellow#Echo("CodeFellow: member completion...")
        let result = <SID>SendMessage("CompleteMember", <SID>getFileName(), line(".") -1, col("."), a:base)
        return result
    endif
endfunction

function codefellow#CompleteScope(findstart, base)
    if a:findstart
        return <SID>getWordUnderCursorIndex()
    else
        silent w!
        call codefellow#Echo("CodeFellow: scope completion...")
        let result = <SID>SendMessage("CompleteScope", <SID>getFileName(), line(".") -1, col("."), a:base)
        return result
    endif
endfunction

"function codefellow#CompleteSmart(findstart, base)
    "if a:findstart
        "return <SID>getWordUnderCursorIndex()
    "else
        "w!
        "call codefellow#Echo("CodeFellow: Please wait...")
"
        "let offset = <SID>getWordBeforeCursorOffset()
        "let result = <SID>SendMessage("CompleteSmart", expand("%:p"), offset, a:base)
"
        "let res = []
        "for entryLine in split(result, "\n")
            "let entry = split(entryLine, ";")
            "call add(res, {'word': entry[0], 'abbr': entry[0] . " (" . entry[1] . ")", 'icase': 0})
        "endfor
        "return res
    "endif
"endfunction

function codefellow#BalloonType()
    let bufmod = getbufvar(bufnr(bufname("%")), "&mod")
    if bufmod == 1
        return "Save buffer to get type information"
    else
        let result = <SID>SendMessage("TypeInfo", <SID>getFileName(), v:beval_lnum -1, v:beval_col)
        return result
    endif
endfunction

function codefellow#PrintTypeInfo()
    let bufmod = getbufvar(bufnr(bufname("%")), "&mod")
    if bufmod == 1
        call codefellow#Echo("Save buffer to get type information")
    else
        echo <SID>SendMessage("TypeInfo", <SID>getFileName(), line(".") - 1, col("."))
    endif
endfunction

function codefellow#ReloadFile()
    return <SID>SendMessage("ReloadFile", <SID>getFileName())
endfunction

function codefellow#CompileFile()
    silent wa!
    exec 'set efm=%f:%l:%c:%m'
    let result = <SID>SendMessage("CompileFile", tempname(), <SID>getFileName())
    call setqflist(result)
    call <SID>ShowCompilerMarkers()
endfunction

function codefellow#Echo(s)
  if g:codefellow_verbose
    exec 'echo '.string(a:s)
  endif
endfunction

