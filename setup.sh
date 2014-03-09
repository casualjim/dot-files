#!/usr/bin/env bash
rm -rf ~/.vimrc ~/.vim ~/.emacs.d ~/.oh-my-zsh ~/.zshrc
curr_dir=$(cd `dirname $0` && pwd)
ln -sf ${curr_dir}/vimreboot ~/.vim
ln -sf ${curr_dir}/vimreboot/vimrc ~/.vimrc
ln -sf ${curr_dir}/ctags ~/.ctags
# ln -sf ${curr_dir}/vim-addons ~/.vim-addons
# ln -sf ${curr_dir}/emacs.d ~/.emacs.d
ln -sf ${curr_dir}/oh-my-zsh ~/.oh-my-zsh
cp ${curr_dir}/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo "Environment has been configured."
