#!/usr/bin/env bash
rm -rf ~/.vimrc ~/.vim ~/.emacs.d
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimfiles ~/.vim
ln -sf ${curr_dir}/_vimrc ~/.vimrc
ln -sf ${curr_dir}/vim-addons ~/.vim-addons
ln -sf ${curr_dir}/emacs.d ~/.emacs.d

echo "Vim and Emacs have been configured."
