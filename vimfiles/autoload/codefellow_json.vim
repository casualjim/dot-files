" copy paste from vim scion backend


" vim encodes strings using ''. JSON requires ".

" dummy type which is used to encode "null"
" same could be done for true / false. But we don't use those yet
fun! codefellow_json#NULL()
  return function("codefellow_json#NULL")
endf
fun! codefellow_json#True()
  return function("codefellow_json#True")
endf
fun! codefellow_json#False()
  return function("codefellow_json#False")
endf
fun! codefellow_json#IntToBool(i)
  return  a:i == 1 ? json#True() : json#False()
endf

fun! codefellow_json#Encode(thing)
  if type(a:thing) == type("")
    return '"'.escape(a:thing,'"').'"'
  elseif type(a:thing) == type({})
    let pairs = []
    for [Key, Value] in items(a:thing)
      call add(pairs, codefellow_json#Encode(Key).':'.codefellow_json#Encode(Value))
      unlet Key | unlet Value
    endfor
    return "{".join(pairs, ",")."}"
  elseif type(a:thing) == type(0)
    return a:thing
  elseif type(a:thing) == type([])
    return '['.join(map(a:thing, "codefellow_json#Encode(v:val)"),",").']'
    return 
  elseif string(a:thing) == string(codefellow_json#NULL())
    return "null"
  elseif string(a:thing) == string(codefellow_json#True())
    return "true"
  elseif string(a:thing) == string(codefellow_json#False())
    return "false"
  else
    throw "unexpected new thing: ".string(a:thing)
  endif
endf

