" {{{1 connection to server / optional server startup
"
" connection string: "socket\nport/auto[\ncommand]"
"                or: "stdin\ncommand"
" socket:
"   if command is given the server will be started automatically
"   if port is set to auto the port will be read from a file which is written
"   by the server (not yet implemented)
"
" stdin:
"   Vim always starts the server and connects to its stdin/out
"
" command must be a list. See example below
"
" Example:
" 
" let p = 'xx'
" let g:codefellow_connection_setting = "stdin\n['java','-cp','"
"   \ .p."/project/boot/scala-2.8.0.RC5/lib/scala-library.jar:"
"   \ .p."/project/boot/scala-2.8.0.RC5/lib/scala-compiler.jar:"
"   \ .p."/codefellow-core/target/scala_2.8.0.RC5/classes', 'de.tuxed.codefellow.Launch']"
"
"  de.tuxed.codefellow.Launch
let p = '~/src/codefellow'
let g:codefellow_connection_setting = "socket\n9081"

let s:self=expand('<sfile>:h')

function s:SetupPython() abort

  if exists('g:codefellow_python_setup')
    return 
  endif

  let g:codefellow_python_setup = 1
  let g:codefellow_python_setup_success = 0

  if !has('python')
    throw "python support required to talk to codefellow server!"
  endif

  if input('connect to codefellow server ? [y/n]:','') != 'y'
    return
  endif

  exec 'pyfile '.s:self.'/codefellow.py'

  " default: user must start server
  if !exists('g:codefellow_connection_setting')
    g:codefellow_connection_setting = "socket\n9081"
  endif

  " create connection object:
  let parts = split(g:codefellow_connection_setting,"\n")
  if parts[0] == 'socket'

    let start_server = len(parts) > 2
    if start_server
      let g:codefellow_server_cmd = eval(parts[2])
    endif
    exec 'py codefellow_connection_object = SocketConnection(vim.eval("parts[1]"),vim.eval("start_server"))'

  elseif parts[0] == 'stdin'

    let g:codefellow_server_cmd = eval(parts[1])
    exec 'py codefellow_connection_object = StdinOutConnection()'

  else
    throw "can't handle connection setting!"
  endif

  let g:codefellow_python_setup_success = 1

endfunction

"
" Sends a message to the CodeFellow server a return the response
"
function codefellow#SendMessage(type, ...)

  call s:SetupPython()

  if !g:codefellow_python_setup_success
    echoe "setting up connection to server failed. :unlet g:codefellow_python_setup and retry"
    " something went wrong (connection failure or no python ..)
    " stay silent
    return ""
  endif

  let msg = codefellow_json#Encode({
        \ 'moduleIdentifierFile': expand("%:p"),
        \ 'message': a:type,
        \ 'arguments': copy(a:000)
        \ })
        \."\nENDREQUEST\n"

  silent! unlet g:codefellow_res
python << EOF
r = codefellow_connection_object.sendMessage(vim.eval("msg"))
# r is valid serialized vim string
vim.command("let g:codefellow_res = "+r)
EOF

  if has_key(g:codefellow_res,'left')
    let exception = g:codefellow_res['left']
    let g:codefellow_last_exception = exception
    throw exception
  elseif has_key(g:codefellow_res,'right')
    return g:codefellow_res['right']
  else
    throw "either left or right key expected"
  endif

endfunction

" }}}

=======

"
" Sends a message to the CodeFellow server a return the response
"
function codefellow#SendMessage(type, ...)
    let msg = codefellow_json#Encode({
                \ 'moduleIdentifierFile': expand("%:p"),
                \ 'message': a:type,
                \ 'arguments': copy(a:000)
                \ })
                \."\nENDREQUEST\n"

    silent! unlet g:codefellow_res

    " DOES NOT WORK ON MY SYSTEM!!!
    "exec 'pyfile ' . expand('<sfile>:h') . '../autoload/codefellow.py'

python << EOF
#import vim
#sc = CodeFellowSocketConnection()
#data = sc.sendMessage(vim.eval("msg"))

# r is valid serialized vim string
#vim.command("let g:codefellow_res = " + data)

import socket
import vim

message = vim.eval("msg")

s = socket.socket()
s.connect(("localhost", 9081))
s.sendall(message)

# read until server closes connection
data = ""
while 1:
  tmp = s.recv(1024)
  if not tmp:
      break
  data += tmp

vim.command("let g:codefellow_res = " + data)
EOF

    if has_key(g:codefellow_res,'left')
        let exception = g:codefellow_res['left']
        let g:codefellow_last_exception = exception
        throw exception
    elseif has_key(g:codefellow_res,'right')
        return g:codefellow_res['right']
    else
        throw "either left or right key expected"
    endif

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
        return s:getWordUnderCursorIndex()
    else
        w!
        call codefellow#Echo("CodeFellow: member completion...")
        let result = codefellow#SendMessage("CompleteMember", s:getFileName(), line(".") -1, col("."), a:base)
        return result
    endif
endfunction

function codefellow#CompleteScope(findstart, base)
    if a:findstart
        return s:getWordUnderCursorIndex()
    else
        w!
        call codefellow#Echo("CodeFellow: scope completion...")
        let result = codefellow#SendMessage("CompleteScope", s:getFileName(), line(".") -1, col("."), a:base)
        return result
    endif
endfunction

"function codefellow#CompleteSmart(findstart, base)
    "if a:findstart
        "return s:getWordUnderCursorIndex()
    "else
        "w!
        "call codefellow#Echo("CodeFellow: Please wait...")
"
        "let offset = s:getWordBeforeCursorOffset()
        "let result = codefellow#SendMessage("CompleteSmart", expand("%:p"), offset, a:base)
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
        let result = codefellow#SendMessage("TypeInfo", s:getFileName(), v:beval_lnum -1, v:beval_col)
        return result
    endif
endfunction

function codefellow#PrintTypeInfo()
    if &modified == 1
        call codefellow#Echo("Save buffer to get type information")
    else
        " reloading of buffer is done on buf write
        echo codefellow#SendMessage("TypeInfo", s:getFileName(), line(".") - 1, col("."))
    endif
endfunction

function codefellow#ReloadFile()
    let s:compilerset=1
    return codefellow#SendMessage("ReloadFile", s:getFileName())
endfunction

function codefellow#CompileFile()
    silent wa!
    exec 'set efm=%f:%l:%c:%m'
    let result = codefellow#SendMessage("CompileFile", s:getFileName())
    call setqflist(result)
    call s:ShowCompilerMarkers()
endfunction

function codefellow#Echo(s)
  if g:codefellow_verbose
    exec 'echo '.string(a:s)
  endif
endfunction

fun! codefellow#EnableDebugging()
  py doDebug=True
  let g:codefellow_verbose = 1
endf

