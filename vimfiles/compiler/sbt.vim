" Vim Compiler File sbt.vim
" Compiler: sbt

if exists("current_compiler")
  finish
endif
let current_compiler = "xsbt"

set makeprg=sbt-without-color\ test-compile
set errorformat=%E[error]\ %f:%l:\ %m,%C[error]\ %p^,%-C%.%#,%Z,
               \%W[warn]\ %f:%l:\ %m,%C[warn]\ %p^,%-C%.%#,%Z,
               \%-G%.%#
set errorfile=target/error