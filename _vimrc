try
  source ~/.vim/vimrc
catch
  source $HOMEPATH\vimfiles\vimrc
  behave mswin
endtry